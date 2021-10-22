//
//  SearchSeedView.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import SwiftUI
import SwiftUIX
import RealmSwift
import SeedHack

struct SearchSeedView: View {
    @ObservedResults(RealmSeed.self, sortDescriptor: SortDescriptor(keyPath: "mGameSeed", ascending: true)) var results
    @State var waterLevel: [WaterLevel] = Array(repeating: .middle, count: 3)
    @State var eventType: [EventType] = Array(repeating: .noevent, count: 3)
    @State var seeds: [UInt32] = []
    @State var isPresented: Bool = false
    @AppStorage("APP_SEARCH_MAX_LENGTH") var maxLength: Int = 65536
    @State var maxAppear: [Int] = Array(repeating: -1, count: 7)
    @State var mGameSeed: UInt32 = 0
    @State var searchStyle: SearchStyle = .exhaustion
    let mShakeTypes: [SalmonType] = [.shakebomber, .shakecup, .shakeshield, .shakesnake, .shaketower, .shakediver, .shakerocket]
    
    let appearLength: [Int] = Range(-1 ... 20).map({ $0 })
    let length: [Int] = Range(16 ... 32).map({ Int(pow(2, Double($0))) })
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Search Mode"), content: {
                    Picker(selection: $searchStyle, label: Text("Search Mode"), content: {
                        ForEach(SearchStyle.allCases, id:\.rawValue) { style in
                            Text("\(style.rawValue) Mode")
                                .tag(style)
                        }
                    })
                        .pickerStyle(SegmentedPickerStyle())
                    
                })
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
                        switch searchStyle {
                            case .exhaustion:
                                findExhaustionSeed()
                            case .database:
                                findDatabaseSeed()
                        }
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
                            ForEach(mShakeTypes) { salmonid in
                                Picker(selection: $maxAppear[Int(salmonid.rawValue)], label: Text(salmonid.localized)) {
                                    ForEach(appearLength, id:\.self) { length in
                                        Text("\(length)")
                                            .tag(length)
                                    }
                                }
                            }
                        })
                    }
                    .font(.system(.body, design: .monospaced))
                    .navigationTitle("Setting")
                }
            })
    }
    
    private func findDatabaseSeed() {
        let eventTypes: [Int8] = eventType.map({ $0.rawValue })
        let waterLevels: [Int8] = waterLevel.map({ $0.rawValue })
        $results.filter = NSPredicate("", valuesIn: <#T##[Int]#>)
        print(results.count)
    }
    
    private func findExhaustionSeed() {
        seeds.removeAll(keepingCapacity: true)
        var results: [UInt32] = Array<UInt32>()
        
        DispatchQueue(label: "FIND SEED").async {
            for initialSeed in Range(0 ... UInt32(maxLength)) {
                if initialSeed & 0x00000FFF == 0x00000000 {
                    DispatchQueue.main.async {
                        mGameSeed = initialSeed
                        seeds = results
                    }
                }
                
                let ocean: Ocean = Ocean(mGameSeed: initialSeed)
                if ocean.mWave.map({ $0.eventType }) == eventType && ocean.mWave.map({ $0.waterLevel }) == waterLevel {
                    if maxAppear.contains(where: { $0 != -1}) {
                        /// 詳細データを検索
                        ocean.getWaveDetail()
                        let appearCount: [Int] = mShakeTypes.map({ salmonid in ocean.bossSalmonidAppearTotal.filter({ $0 == salmonid }).count })
                        if !zip(appearCount, maxAppear).map({ $1 == -1 ? true : $0 <= $1 }).contains(false) {
                            results.append(initialSeed)
                        }
                    } else {
                        results.append(initialSeed)
                    }
                }
            }
            /// 最後に調整する
            DispatchQueue.main.async {
                mGameSeed = UInt32(maxLength)
                seeds = results
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

extension NSPredicate {
    public convenience init(_ property: String, valuesIn values: [Int]) {
        self.init(format: "\(property) IN %@", argumentArray: [values])
    }
}
