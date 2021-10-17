//
//  SettingView.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/17.
//

import Foundation
import SwiftUI
import SeedHack
import Benchmark

struct SettingView: View {
    let eventTypes: [SeedManager.FileType] = [.code(.rush), .code(.griller), .code(.fog), .code(.cohock)]
    
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
            Section(header: Text("Benchmark"), content: {
                Button(action: {
                    benchmark("Benchmark") {
                        for mGameSeed in Range(0 ... Int16.max) {
                            let ocean: Ocean = Ocean(mGameSeed: Int32(mGameSeed))
                        }
                    }
                    Benchmark.main()
                }, label: {
                    Text("Run")
                })
            })
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
