//
//  SeedManager.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/17.
//

import Foundation
import RealmSwift
import SWCompression
import Combine
import SeedHack
import SwiftUI

final class SeedManager: ObservableObject {
    private init() {
        let schemeVersion: UInt64 = 0
        do {
            self.realm = try Realm()
        } catch {
            var config = Realm.Configuration.defaultConfiguration
            config.schemaVersion = schemeVersion
            config.deleteRealmIfMigrationNeeded = true
            self.realm = try! Realm(configuration: config, queue: .main)
        }
    }
    
    private let realm: Realm
    private var task = Set<AnyCancellable>()
    
    static let shared: SeedManager = SeedManager()
    @Published var binaryFiles: [LoadSeedType] = []
    
    private func save<T: Object>(_ objects: [T]) {
        if realm.isInWriteTransaction {
            for object in objects {
                realm.create(T.self, value: object, update: .all)
            }
        } else {
            realm.beginWrite()
            for object in objects {
                realm.create(T.self, value: object, update: .all)
            }
            try? realm.commitWrite()
        }
    }
    
    func object<T: Object>(_ type: T.Type, forPrimaryKey key: String?) -> T? {
        realm.object(ofType: type, forPrimaryKey: key)
    }
    
    func objects<T: Object>(_ type: T.Type) -> Results<T> {
        realm.objects(type)
    }
    
    func save<T: Object>(_ object: T) {
        self.save([object])
    }
    
    func updateMemo<T: Object>(_ object: T, memo: String) {
        if let object = object as? RealmSeed {
            if realm.isInWriteTransaction {
                object.mTitle = memo
            } else {
                realm.beginWrite()
                object.mTitle = memo
                try? realm.commitWrite()
            }
        }
    }
    
    private func loadSeadList(_ type: FileType) -> AnyPublisher<[String], APPError> {
        Deferred {
            Future { promise in
                if let path = Bundle.main.path(forResource: type.rawValue, ofType: "bin") {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                        if let binary = try? BZip2.decompress(data: data) {
                            if let text = String(data: binary, encoding: .ascii) {
                                promise(.success(text.split(separator: "\n").map({ String($0) })))
                            } else {
                                promise(.failure(.invalidData))
                            }
                        } else {
                            promise(.failure(.fileBroken))
                        }
                    } else {
                        promise(.failure(.invalidData))
                    }
                } else {
                    promise(.failure(.invalidPath))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func addDefaultSeed(_ fileType: FileType) {
        SeedManager.shared.loadSeadList(fileType).sink(receiveCompletion: { completion in
        }, receiveValue: { response in
            let lists = response.chunked(by: 50000)
            for list in lists {
                SeedManager.shared.save(list.map({ RealmSeed(ocean: Ocean(mGameSeed: UInt32($0, radix: 16)!)) }))
            }
        })
            .store(in: &task)
    }
    
    class LoadSeedType: Identifiable {
        internal init(fileType: FileType.WaveEventCode) {
            self.fileType = fileType
            self.enabled = UserDefaults.standard.bool(forKey: "INITIAL_SEED_\(fileType.rawValue.capitalized)")
        }
        
        let fileType: FileType.WaveEventCode
        let enabled: Bool
    }
    
    enum FileType {
        public enum Package {
            public static let namespace = "Seeds"
            public static let version = "1.0.0"
        }
        
        case code(WaveEventCode)
        case event(Event)
        
        enum Event: Int, CaseIterable {
            case noevent
            case rush
            case goldie
            case griller
            case fog
            case mothership
            case cohock
        }
        
        enum WaveEventCode: String, CaseIterable {
            case noevents   = "NoEvents"
            case hightide   = "202020"
            case lowtide    = "000000"
            case rush       = "222122"
            case griller    = "222322"
            case fog        = "222422"
            case mothership = "222522"
            case cohock     = "222622"
        }
        
        public var rawValue: String {
            switch self {
                case .code(let event):
                    return event.rawValue
                default:
                    return "-"
            }
        }
    }
    
}

enum APPError: Int, Error, CaseIterable {
    /// ファイルが存在しない
    case notFound
    /// データがない
    case invalidPath
    /// BZip2から復号不可
    case fileBroken
    /// Hexから文字列に変換不可
    case invalidData
    
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
