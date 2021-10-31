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
    @State var arm64: String?
    
    init(mGameSeed: UInt32) {
        self.mGameSeed = String(format: "%08X", mGameSeed)
        self.ocean = Ocean(mGameSeed: mGameSeed)
        self.ocean.getWaveDetail()
    }
    
    var body: some View {
        Form {
            Section(header: Text("Wave"), content: {
                ForEach(ocean.mWave) { wave in
                    WaveInfoView(wave: wave)
                }
            })
            Section(header: Text("Boss Salmonids"), content: {
                ForEach(SalmonType.allCases) { salmonid in
                    HStack(content: {
                        Text(salmonid.localized)
                        Spacer()
                        Text("\(ocean.bossSalmonidAppearTotal.filter({ $0 == salmonid }).count)")
                            .foregroundColor(.secondary)
                    })
                }
            })
            Section(header: Text("IPSwitch"), content: {
                Button(action: {
                    UIPasteboard.general.setValue(arm64 ?? "", forPasteboardType: "public.plain-text")
                }, label: {
                    HStack(content: {
                        Spacer()
                        Text(arm64 ?? "")
                            .foregroundColor(.secondary)
                    })
                })
            })
        }
        .navigationTitle(mGameSeed)
        .onAppear {
            DispatchQueue(label: "Converter").async(execute: {
                Converter.convert(mGameSeed, completion: { result in
                    switch result {
                        case .success(let value):
                            self.arm64 = value
                        case .failure(let error):
                            print(error)
                    }
                })
                
            })
        }
        .toolbar(content: {
            ToolbarItemGroup {
                SaveButton(mGameSeed: mGameSeed)
            }
        })
        .font(.system(.body, design: .monospaced))
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
