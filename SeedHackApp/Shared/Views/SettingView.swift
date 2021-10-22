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

struct SettingView: View {
    @ObservedResults(RealmSeed.self, sortDescriptor: SortDescriptor(keyPath: "mGameSeed", ascending: true)) var results
    let eventTypes: [SeedManager.FileType] = [.code(.rush), .code(.griller), .code(.fog), .code(.mothership), .code(.noevents)]
    
    var body: some View {
        List {
            Section(header: Text("Load Event Database"), content: {
                ForEach(eventTypes, id:\.rawValue) { fileType in
                    Button(action: {
                        SeedManager.shared.addDefaultSeed(fileType)
                    }, label: {
                        Text("Load \(fileType.rawValue).bin")
                    })
                }
            })
            Section(header: Text("Database"), content: {
                HStack(content: {
                    Text("Records")
                    Spacer()
                    Text("\(results.count)")
                })
            })
            Section(header: Text("Benchmark"), content: {
                Button(action: {
                    Benchmark.main()
                }, label: {
                    Text("Run")
                })
            })
        }.onAppear {
            benchmark("Benchmark") {
                for mGameSeed in UInt32(0x00000) ... UInt32(0xFFFFF) {
                    _ = Ocean(mGameSeed: UInt32(mGameSeed))
                }
            }
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
