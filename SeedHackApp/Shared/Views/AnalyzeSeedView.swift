//
//  AnalyzeSeedView.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import SwiftUI
import SwiftUIX
import SeedHack

struct AnalyzeSeedView: View {
    @State var initialSeed: String? = "0"
    @ObservedObject var ocean: Ocean = Ocean(mGameSeed: 0)
    let alphabet: [String] = "0123456789ABCDEF".map({ String($0) })
    
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
                            Text("\(ocean.bossSalmonidAppearTotal.filter({ $0 == salmonid }).count)")
                                .foregroundColor(.secondary)
                        })
                    }
                })
            }
            .navigationSearchBar({
                SearchBar("Input the initial seed", text: $initialSeed, onEditingChanged: { _ in
                    // 数字以外があれば全て数字に変換する
                    if let initialSeed = initialSeed {
                        self.initialSeed = initialSeed.map({ String($0).uppercased() }).filter({ alphabet.contains($0) }).joined()
                    }
                }, onCommit: {
                    if let initialSeed = initialSeed, let mGameSeed = Int64(initialSeed, radix: 16) {
                        ocean.setGameSeed(mGameSeed: mGameSeed)
                        ocean.getWaveInfo()
                    }
                })
                    .keyboardType(.alphabet)
            })
            .navigationTitle("Analyze Seed")
        }
        .font(.system(.body, design: .monospaced))
        .navigationViewStyle(SplitNavigationViewStyle())
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
            case .noevent, .fog, .cohockcharge:
                ScrollView {
                    ForEach(wave.mWaveUpdateEventArray) { wave in
                        HStack(content: {
                            Text(String(format: "%d", wave.appearType.rawValue))
                            Spacer()
                            LazyVGrid(columns: Array(repeating: .init(.fixed(50)), count: wave.salmonid.count), alignment: .trailing, spacing: nil, pinnedViews: [], content: {
                                ForEach(wave.salmonid.indices) { index in
                                    Image(wave.salmonid[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            })
                        })
                            .padding(.horizontal)
                        Divider()
                    }
                }
                .navigationTitle("Wave \(wave.index + 1)")
            case .goldieseeking:
                ScrollView {
                    ForEach(wave.mGeyserArray) { geyser in
                        HStack(content: {
                            Text(alphabet[geyser.succ])
                            Spacer()
                            Text(alphabet[geyser.dest])
                        })
                            .padding(.horizontal)
                        Divider()
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

extension Ocean.WaveUpdateEvent: Identifiable {
    public var id: UUID { UUID() }
}

extension Ocean.Wave: Identifiable {
    public var id: Int64 { mWaveSeed }
}

extension Ocean {
    var bossSalmonidAppearTotal: [Ocean.SalmonType] {
        self.mWave.flatMap({ $0.mWaveUpdateEventArray.flatMap({ $0.salmonid })})
    }
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
            case .shakegoldie:
                return "Goldie"
            case .shakedozer:
                return "Griller"
        }
    }
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
            case .shakegoldie:
                return 3
            case .shakedozer:
                return 16
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
