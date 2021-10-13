//
//  AnalyzeSeedView.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import SwiftUI
import SwiftUIX
import SeedHack
import WebKit

struct AnalyzeSeedView: View {
    @State var initialSeed: String? = "4"
    @ObservedObject var ocean: Ocean = Ocean(mGameSeed: 0)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Wave"), content: {
                    ForEach(ocean.mWave) { wave in
                        WaveInfo(wave: wave)
                    }
                })
                Section(header: Text("Boss Salmonids"), content: {
                    ForEach(Ocean.SalmonType.allCases) { salmonid in
                        HStack(content: {
                            Text(salmonid.localized)
                            Spacer()
                            Text("\(ocean.mWave.flatMap({ $0.mBossArray }).filter({ $0 == salmonid }).count)")
                                .foregroundColor(.secondary)
                        })
                    }
                })
            }
            .navigationSearchBar({
                SearchBar("Input the initial seed", text: $initialSeed, onEditingChanged: { _ in
                    // 数字以外があれば全て数字に変換する
                    if let initialSeed = initialSeed, let mGameSeed = Int64(initialSeed) {
                        ocean.setGameSeed(mGameSeed: mGameSeed)
                        ocean.getWaveInfo()
                        print(ocean.mWave)
                    }
                }, onCommit: {
                    
                })
                    .keyboardType(.numberPad)
            })
            .navigationTitle("Analyze Seed")
        }
    }
}

struct WaveInfo: View {
    let wave: Ocean.Wave
    
    init(wave: Ocean.Wave) {
        self.wave = wave
        self.wave.getWaveArray()
    }
    
    var body: some View {
        NavigationLink(destination: WaveDetail(wave: wave), label: {
            VStack(alignment: .leading, content: {
                Text(wave.waterLevel.localized)
                Text(wave.eventType.localized)
            })
        })
    }
}

struct WaveDetail: View {
    let wave: Ocean.Wave
    let alphabet: [String] = "ABCDEFGHI".map({ String($0) })
    
    var body: some View {
        switch wave.eventType {
            case .noevent, .cohockcharge:
                List {
                    ForEach(wave.mBossArray) { salmonId in
                        Image(salmonId)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45)
                    }
                }
                .navigationTitle("Wave")
            case .goldieseeking:
                List {
                    ForEach(wave.mGeyserArray) { geyser in
                        HStack(content: {
                            Text(alphabet[geyser.succ])
                            Spacer()
                            Text(alphabet[geyser.dest])
                        })
                    }
                }
                .navigationTitle("Geyser")
            default:
                EmptyView()
        }
    }
}

struct AnalyzeSeedView_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzeSeedView()
    }
}

extension GeyserPosition: Identifiable {
    public var id: UUID { UUID() }
}

extension Ocean.SalmonType: Identifiable {
    public var id: UUID { UUID() }
}

extension Ocean.SalmonType {
    var localized: String {
        switch self {
            case .shakebomber:
                return "Steelhead"
            case .shakecup:
                return "Flyfish"
            case .shakeshield:
                return "Scrapper"
            case .shakesnake:
                return "Steel Eel"
            case .shaketower:
                return "Tower"
            case .shakediver:
                return "Maws"
            case .shakerocket:
                return "Drizzler"
        }
    }
}

extension Ocean.Wave: Identifiable {
    public var id: Int64 { mWaveSeed }
}

extension Ocean.EventType {
    var localized: String {
        switch self {
            case .noevent:
                return "-"
            case .rush:
                return "Rush"
            case .goldieseeking:
                return "Goldie Seeking"
            case .griller:
                return "Griller"
            case .fog:
                return "Fog"
            case .mothership:
                return "The Mothership"
            case .cohockcharge:
                return "Cohock Charge"
        }
    }
}

extension Ocean.SalmonType {
    var internalId: Int {
        switch self {
            case .shakebomber:
                return 6
            case .shakecup:
                return 9
            case .shakeshield:
                return 12
            case .shakesnake:
                return 13
            case .shaketower:
                return 14
            case .shakediver:
                return 15
            case .shakerocket:
                return 19
        }
    }
}

extension Ocean.WaterLevel {
    var localized: String {
        switch self {
            case .low:
                return "LT"
            case .middle:
                return "NT"
            case .high:
                return "HT"
        }
    }
}
