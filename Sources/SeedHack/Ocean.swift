//
//  Ocean.swift
//  
//
//  Created by devonly on 2021/10/13.
//

import Foundation

final class Ocean {
    /// 初期ゲームシード
    private(set) var mGameSeed: Int64
    /// WAVE情報
    private(set) var mWave: [Wave]
    /// 擬似乱数生成器
    private let mWaveArray: [[UpdateType]] = [
        [2, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0].compactMap({ UpdateType(rawValue: $0) })
    ]
    
    init(mGameSeed: Int64) {
        self.mGameSeed = mGameSeed
        let rnd: Random = Random(seed: mGameSeed)
        rnd.getU32()
        self.mWave = [
            Wave(0, mGameSeed, mWaveArray[0]),
            Wave(1, rnd.getU32(), mWaveArray[1]),
            Wave(2, rnd.getU32(), mWaveArray[2])
        ]
    }
    
    func setGameSeed(mGameSeed: Int64) {
        self.mGameSeed = mGameSeed
        let rnd: Random = Random(seed: mGameSeed)
        rnd.getU32()
        self.mWave = [
            Wave(0, mGameSeed,    mWaveArray[0]),
            Wave(1, rnd.getU32(), mWaveArray[1]),
            Wave(2, rnd.getU32(), mWaveArray[2])
        ]
    }
    
    func getWaveInfo() {
        let rnd: Random = Random(seed: mGameSeed)
        var sum: Int64 = 0
        
        for wave in mWave {
            for eventType in EventType.allCases {
                if wave.index > 0 && mWave[wave.index - 1].eventType != .noevent && mWave[wave.index - 1].eventType == eventType {
                    continue
                }
                sum += eventType.prob
                if (rnd.getU32() * sum) >> 0x20 < eventType.prob {
                    wave.eventType = eventType
                }
            }
            
            sum = 0
            for waterLevel in WaterLevel.allCases {
                if waterLevel == .low && [EventType.rush, EventType.goldieseeking, EventType.griller].contains(wave.eventType) {
                    continue
                }
                sum += waterLevel.prob
                if (rnd.getU32() * sum) >> 0x20 < waterLevel.prob {
                    wave.waterLevel = wave.eventType == .cohockcharge ? .low : waterLevel
                }
            }
        }
    }
    
    /// WAVE情報を持つクラス
    class Wave {
        internal init(_ index: Int, _ initialSeed: Int64, _ waveArray: [UpdateType]) {
            self.index = index
            self.mWaveSeed = initialSeed
            self.mWaveArray = waveArray
            getWaveArray()
        }
        
        let index: Int
        private var mWaveArray: [UpdateType]
        var mWaveSeed: Int64 = 0
        var mEnemyAppearId: [Int] = [-1]
        var bossSalmonId: [SalmonType] = []
        var eventType: EventType = .noevent
        var waterLevel: WaterLevel = .middle
        
        func getWaveArray() {
            let rnd: Random = Random(seed: self.mWaveSeed)
            rnd.getU32()
            
            for (index, type) in mWaveArray.enumerated() {
                guard let mLastEnemyAppearId = mEnemyAppearId.last else { return }
                switch type {
                    case .update:
                        mEnemyAppearId.append(getEnemyAppearId(random: rnd.getU32(), mEnemyAppearId: mLastEnemyAppearId))
                    case .change:
                        mEnemyAppearId.append(getEnemyAppearId(random: rnd.getU32(), mEnemyAppearId: mLastEnemyAppearId))
                    case .appear:
                        bossSalmonId.append(getEnemyId(mEnemySeed: rnd.getU32()))
                    case .none:
                        break
                }
            }
        }
        
        private func getEnemyId(mEnemySeed: Int64) -> SalmonType {
            let rnd: Random = Random(seed: mEnemySeed)
            var mRareId: SalmonType = .shakebomber
            
            for salmonId in SalmonType.allCases {
                if !Bool((rnd.getU32() * (salmonId.rawValue + 1)) >> 0x20) {
                    mRareId = salmonId
                }
            }
            return mRareId
        }
        
        private func getEnemyAppearId(random: Int64, mEnemyAppearId: Int) -> Int {
            var id = mEnemyAppearId
            let mArray: [Int] = [1, 2, 3]
            var mPtr: Int = 0
            var w6: Int64 = 3
            var x6: Int = 3
            let v5: Int = id
            let w7: [Int] = mArray
            
            if !Bool(id & 0x80000000) {
                var w8: Int64 = w6 - 1
                while true {
                    let v17 = w8
                    let w9 = w7[mPtr]
                    if w9 < id {
                        break
                    }
                    w6 -= w9 == id ? 1 : 0
                    if w9 == id {
                        break
                    }
                    w8 = v17 - 1
                    mPtr += 1
                    if !Bool(v17) {
                        break
                    }
                }
            }
            
            mPtr = 0
            let x7: [Int] = mArray
            var x8: Int64 = 0xFFFFFFFF & ((random * w6) >> 0x20)
            
            while true {
                let x9: Int = x7[mPtr]
                let x10: Int64 = max(0, x8 - 1)
                let x11: Int = x8 == 0 ? x9 : v5
                let x12: Int = x9 == v5 ? 5 :Int(x8 == 0)
                
                if x9 != v5 {
                    x8 = 0xFFFFFFFF & x10
                    id = x11
                }
                if (x12 & 7) != 5 && Bool(x12 & 7) {
                    break
                }
                x6 -= 1
                mPtr += 1
                if !Bool(x6) {
                    return v5
                }
            }
            return id
        }
    }
    
    enum UpdateType: Int, CaseIterable {
        /// 湧き方向変化
        case change
        /// オオモノ出現
        case appear
        /// 乱数のみアップデート
        case update
        /// なにもしない
        case none
    }
    
    enum SalmonType: Int64, CaseIterable {
        case shakebomber
        case shakecup
        case shakeshield
        case shakesnake
        case shaketower
        case shakediver
        case shakerocket
        
        /// 重み
        var prob: Int64 { 1 }
    }
    
    enum WaterLevel: Int, CaseIterable {
        /// 干潮
        case low
        /// 通常
        case middle
        /// 満潮
        case high
        
        /// 重み
        var prob: Int64 {
            switch self {
                case .low:
                    return 1
                case .middle:
                    return 3
                case .high:
                    return 1
            }
        }
    }
    
    enum EventType: Int, CaseIterable {
        case noevent
        case rush
        case goldieseeking
        case griller
        case mothership
        case fog
        case cohockcharge
        
        /// 重み
        var prob: Int64 {
            switch self {
                case .noevent:
                    return 18
                default:
                    return 1
            }
        }
    }
}

extension Bool {
    init(_ value: Int) {
        self.init(value != 0)
    }
    
    init(_ value: Int64) {
        self.init(value != 0)
    }
}

extension Int {
    init(_ value: Bool) {
        self.init(value ? 1 : 0)
    }
}
