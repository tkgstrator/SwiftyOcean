//
//  DetailView.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/14.
//

import SwiftUI
import SwiftUIX
import SeedHack

struct DetailView: View {
    let mGameSeed: String
    let ocean: Ocean
    
    init(mGameSeed: UInt32) {
        self.mGameSeed = String(format: "%08X", mGameSeed)
        self.ocean = Ocean(mGameSeed: mGameSeed)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Wave"), content: {
                ForEach(ocean.mWave) { wave in
                    WaveInfo(wave: wave)
                }
            })
            Section(header: Text("Boss Salmonids"), content: {
//                ForEach(SalmonType.allCases) { salmonid in
//                    HStack(content: {
//                        Text(salmonid.localized)
//                        Spacer()
//                        Text("\(ocean.bossSalmonidAppearTotal.filter({ $0 == salmonid }).count)")
//                            .foregroundColor(.secondary)
//                    })
//                }
            })
        }
        .navigationTitle(mGameSeed)
        .font(.system(.body, design: .monospaced))
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
