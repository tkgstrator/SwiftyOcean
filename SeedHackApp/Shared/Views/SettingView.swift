//
//  SettingView.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/17.
//

import Foundation
import SwiftUI
import RealmSwift
import SeedHack
import Benchmark
import SwiftUIX

struct SettingView: View {
    @EnvironmentObject var  manager: SeedManager
    @ObservedResults(RealmSeed.self, sortDescriptor: SortDescriptor(keyPath: "mGameSeed", ascending: true)) var results
    
    @State var eventTypes: [SeedManager.FileType] = [.code(.rush), .code(.griller), .code(.fog), .code(.mothership), .code(.noevents)]
    @AppStorage("INITIAL_LOADED_SEED") var loadedFlag: [Bool] = Array(repeating: false, count: 5)
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Load Event Database"), content: {
                    ForEach(Array(eventTypes.enumerated()), id:\.offset) { offset, eventType in
                        Button(action: {
                            SeedManager.shared.addDefaultSeed(eventType)
                            loadedFlag[offset].toggle()
                        }, label: {
                            Text("Load \(eventType.rawValue).bin")
                        }).disabled(loadedFlag[offset])
                    }
                })
                Section(header: Text("Database"), content: {
                    HStack(content: {
                        Text("Records")
                        Spacer()
                        Text("\(results.count)")
                    })
                    NavigationLink(destination: SavedSeedView(), label: {
                        Text("Saved")
                    })
                })
                Section(header: Text("Development"), content: {
                    Button(action: {
                        Benchmark.main()
                    }, label: {
                        Text("Benchmark")
                    })
                    Button(action: {
                        loadedFlag = Array(repeating: false, count: 5)
                    }, label: {
                        Text("Reset")
                    })
                })
            }.onAppear {
                benchmark("Benchmark") {
                    for mGameSeed in UInt32(0x00000) ... UInt32(0xFFFFF) {
                        _ = Ocean(mGameSeed: UInt32(mGameSeed))
                    }
                }
            }
            .navigationTitle("Setting")
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

extension Array where Element == String {
    var chunked: [String] {
        return stride(from: 0, to: self.count, by: 8).map({
            Array(self[$0 ..< Swift.min($0 + 8, self.count)]).joined()
        })
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
