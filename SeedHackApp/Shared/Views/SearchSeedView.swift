//
//  SearchSeedView.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import SwiftUI
import SwiftUIX
import SeedHack

struct SearchSeedView: View {
    @State var waterLevel: [WaterLevel] = Array(repeating: .middle, count: 3)
    @State var eventType: [EventType] = Array(repeating: .noevent, count: 3)
    @State var seeds: [UInt32] = []
    @State var isPresented: Bool = false
    @AppStorage("APP_SEARCH_MAX_LENGTH") var maxLength: Int = 65536
    @State var maxAppear: [Int] = Array(repeating: -1, count: 7)
    @State var mGameSeed: UInt32 = 0
    
    let appearLength: [Int] = Range(-1 ... 20).map({ $0 })
    let length: [Int] = Range(16 ... 32).map({ Int(pow(2, Double($0))) })
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Range(0 ... 2)) { index in
                    Section(header: "Wave \(index + 1)", content: {
                        Picker(selection: $waterLevel[index], label: Text("Tide")) {
                            ForEach(WaterLevel.allCases.reversed()) { waterLevel in
                                Text(waterLevel.localized)
                                    .tag(waterLevel)
                            }
                        }
                        Picker(selection: $eventType[index], label: Text("Event")) {
                            ForEach(EventType.allCases) { eventType in
                                Text(eventType.localized)
                                    .tag(eventType)
                            }
                        }
                    })
                }
                .font(.system(.body, design: .monospaced))
                HStack(content: {
                    Button(action: {
                        findSeed()
                    }, label: {
                        Text("Find")
                    })
                    Spacer()
                    Text("\(seeds.count)")
                        .foregroundColor(.secondary)
                })
                .font(.system(.body, design: .monospaced))
                NavigationLink(destination: ResultView, label: {
                    Text("Result")
                })
                ProgressView(value: Double(mGameSeed) / Double(maxLength))
                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
            }
            .navigationBarItems(trailing: SettingButton)
            .navigationTitle("Find Seed")
        }
        .navigationViewStyle(SplitNavigationViewStyle())
    }
    
    var ResultView: some View {
        List {
            ForEach(seeds.prefix(100), id:\.self) { seed in
                NavigationLink(destination: DetailView(mGameSeed: seed), label: {
                    Text(String(format: "%08X", seed))
                })
            }
        }
        .font(.system(.body, design: .monospaced))
        .navigationTitle("Result")
    }
    
    var SettingButton: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            Image(.setting)
        })
            .sheet(isPresented: $isPresented, onDismiss: {}, content: {
                NavigationView {
                    Form {
                        Section(header: "Global", content: {
                            Picker(selection: $maxLength, label: Text("Max length")) {
                                ForEach(length, id:\.self) { length in
                                    Text("\(length)")
                                        .tag(length)
                                }
                            }
                        })
                        Section(header: "Boss Salmonids", content: {
//                            ForEach(SalmonType.normal) { salmonid in
//                                Picker(selection: $maxAppear[Int(salmonid.rawValue)], label: Text(salmonid.localized)) {
//                                    ForEach(appearLength, id:\.self) { length in
//                                        Text("\(length)")
//                                            .tag(length)
//                                    }
//                                }
//                            }
                        })
                    }
                    .font(.system(.body, design: .monospaced))
                    .navigationTitle("Setting")
                }
            })
    }
    
    private func findSeed() {
        seeds.removeAll(keepingCapacity: true)
        DispatchQueue(label: "FindSeed").async {
            for initialSeed in Range(0 ... UInt32(maxLength)) {
                DispatchQueue.main.async {
                    self.mGameSeed = initialSeed
                }
                let ocean: Ocean = Ocean(mGameSeed: initialSeed)
                if ocean.mWave.map({ $0.eventType }) == eventType && ocean.mWave.map({ $0.waterLevel }) == waterLevel {
//                    if maxAppear.contains(where: { $0 != -1}) {
//                        let _ = ocean.mWave.map({ $0.getWaveArray() })
//////                        let appearCount: [Int] = SalmonType.normal.map({ salmonid in ocean.bossSalmonidAppearTotal.filter({ $0 == salmonid }).count })
////                        if !zip(appearCount, maxAppear).map({ $1 == -1 ? true : $0 <= $1 }).contains(false) {
//                            seeds.append(initialSeed)
//                        }
//                    } else {
//                        seeds.append(initialSeed)
//                    }
                }
            }
        }
        
    }
}

struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}

extension WaterLevel: Identifiable {
    public var id: Int8 { rawValue }
}

extension EventType: Identifiable {
    public var id: Int8 { rawValue }
}

extension ActionSheet: Identifiable {
    public var id: UUID { UUID() }
}

struct SearchSeedView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSeedView()
    }
}
