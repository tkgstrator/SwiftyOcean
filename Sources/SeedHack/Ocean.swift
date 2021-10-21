//
//  Ocean.swift
//  
//
//  Created by devonly on 2021/10/13.
//

import Foundation

public final class Ocean: Random {
    /// 初期ゲームシード
    public private(set) var mGameSeed: UInt32
    /// WAVE情報
    public var mWave: [Wave] = Array<Wave>()
    /// WAVE情報更新タイミング配列
//    private let mWaveArray: [[UpdateType]] = [
//        [2, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
//        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
//        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0].compactMap({ UpdateType(rawValue: $0) })
//    ]
    static let eventTypes: [EventType] = [.noevent, .rush, .goldieseeking, .griller, .fog, .mothership, .cohockcharge]
    static let waterLevels: [WaterLevel] = [.low, .middle, .high]
    
    public init(mGameSeed: UInt32) {
        self.mGameSeed = mGameSeed
        // 乱数生成器を初期化
        super.init(seed: mGameSeed)
        self.mWave = getWaveInfo()
    }
    
    deinit {}
    
    private func getWaveInfo() -> [Wave] {
        // 最初に一回乱数を無駄に生成
        getU32()
        
        // WAVE決定用の乱数生成器
        let rnd: Random = Random(seed: mGameSeed)
        let mWaves: [UInt32] = [mGameSeed, getU32(), getU32()]
        var mWave: [Wave] = Array<Wave>()
        
        for (index, mWaveSeed) in mWaves.enumerated() {
            var mEventProb: UInt32 = 0
            var mWaterProb: UInt32 = 0
            var mEventType: EventType = .noevent
            var mWaterLevel: WaterLevel = .low
            
            for eventType in Ocean.eventTypes  {
                if index != 0 && mWave[index - 1].eventType != .noevent && mWave[index - 1].eventType == eventType {
                    continue
                }
                
                mEventProb += eventType.prob
                if (UInt64(rnd.getU32()) &* UInt64(mEventProb)) >> 0x20 < eventType.prob {
                    mEventType = eventType
                }
            }
            
            for waterLevel in Ocean.waterLevels {
                if waterLevel == .low && mEventType.rawValue >= 1 && mEventType.rawValue <= 3 {
                    continue
                }
                mWaterProb += waterLevel.prob
                if (UInt64(rnd.getU32()) &* UInt64(mWaterProb)) >> 0x20 < waterLevel.prob {
                    mWaterLevel = mEventType == .cohockcharge ? .low : waterLevel
                }
            }
            mWave.append(Wave(mWaveSeed: mWaveSeed, waterLevel: mWaterLevel, eventType: mEventType))
        }
        return mWave
    }
    
    /// WAVE情報を持つクラス
    public class Wave: Random {
        internal init(mWaveSeed: UInt32, waterLevel: WaterLevel, eventType: EventType) {
            self.mWaveSeed = mWaveSeed
            self.waterLevel = waterLevel
            self.eventType = eventType
            super.init()
        }
        
//        private var mWaveArray: [UpdateType]
        public var mWaveSeed: UInt32 = 0
//        public var mWaveUpdateEventArray: [WaveUpdateEvent] = []
//        public var mGeyserArray: [GeyserPosition] = []
        public var eventType: EventType
        public var waterLevel: WaterLevel
        
//        public func getWaveArray() {
//            // イベント内容で分岐
//            switch eventType {
//                case .noevent, .cohockcharge, .fog:
//                    mWaveUpdateEventArray = getEnemyArray()
//                case .rush:
//                    break
//                case .goldieseeking:
//                    mGeyserArray = getGeyserArray(.shakeride, waterLevel: waterLevel)
//                case .griller:
//                    break
//                case .mothership:
//                    break
//            }
//        }
        
//        private func getEnemyArray() -> [WaveUpdateEvent] {
//            let rnd: Random = Random(seed: self.mWaveSeed)
//            rnd.getU32()
//
//            var mWaveEventArray: [WaveUpdateEvent] = []
//            var mBossArray: [SalmonType] = []
//            var mEnemyAppearId: [AppearType] = [.none]
//
//            for type in mWaveArray {
//                guard let mLastEnemyAppearId = mEnemyAppearId.last else { return [] }
//                switch type {
//                    case .update:
//                        // 一回無駄に消化
//                        getEnemyAppearId(random: rnd.getU32(), mEnemyAppearId: mLastEnemyAppearId)
//                    case .change:
//                        guard let appearId: AppearType = AppearType(rawValue: getEnemyAppearId(random: rnd.getU32(), mEnemyAppearId: mLastEnemyAppearId)) else { return [] }
//                        if !mBossArray.isEmpty {
//                            mWaveEventArray.append(WaveUpdateEvent(index: mWaveEventArray.count, appearType: mLastEnemyAppearId, salmonid: mBossArray))
//                            mBossArray.removeAll()
//                        }
//                        mEnemyAppearId.append(appearId)
//                    case .appear:
//                        switch eventType {
//                            case .fog:
//                                if (mWaveEventArray.flatMap({ $0.salmonid }).count + mBossArray.count + 1) % 5 == 0 {
//                                    rnd.getU32()
//                                    mBossArray.append(.shakegoldie)
//                                } else {
//                                    mBossArray.append(getEnemyId(mEnemySeed: rnd.getU32()))
//                                }
//                            default:
//                                mBossArray.append(getEnemyId(mEnemySeed: rnd.getU32()))
//                        }
//                    case .none:
//                        break
//                }
//            }
//            return mWaveEventArray
//        }
//
//        private func getGeyserArray(_ stage: StageType, waterLevel: WaterLevel) -> [GeyserPosition] {
//            let rnd: Random = Random(seed: mWaveSeed)
//            // 潮位とステージに合わせた配列を読み込む
//            var geyser: [GeyserType] = waterLevel == .middle ? stage.middle : stage.high
//            var position: [GeyserPosition] = []
//
//            for _ in 0 ... 15 {
//                for sel in (1 ... (geyser.count - 1)).reversed() {
//                    let index: Int64 = (rnd.getU32() * Int64(sel + 1)) >> 0x20
//                    geyser.swapAt(Int(sel), Int(index))
//                }
//                guard let firstGeyser = geyser.first else { return [] }
//
//                if firstGeyser.mFlag {
//                    let index: Int64 = (rnd.getU32() * Int64(firstGeyser.mDest.count)) >> 0x20
//                    position.append(GeyserPosition(succ: firstGeyser.mSucc, dest: firstGeyser.mDest[Int(index)]))
//                } else {
//                    position.append(GeyserPosition(succ: firstGeyser.mSucc, dest: firstGeyser.mDest.first ?? 0))
//                }
//            }
//            return position
//        }
//
//        /// 出現するオオモノシャケの種類を返す
//        private func getEnemyId(mEnemySeed: Int64) -> SalmonType {
//            let rnd: Random = Random(seed: mEnemySeed)
//            var mRareId: SalmonType = .shakebomber
//
//            for salmonId in SalmonType.normal {
//                if !Bool((rnd.getU32() * (salmonId.rawValue + 1)) >> 0x20) {
//                    mRareId = salmonId
//                }
//            }
//            return mRareId
//        }
//
//        /// シャケが出現する湧き方向を返す
//        @discardableResult
//        private func getEnemyAppearId(random: Int64, mEnemyAppearId: AppearType) -> Int {
//            getEnemyAppearId(random: random, mEnemyAppearId: mEnemyAppearId.rawValue)
//        }
//
//        /// シャケが出現する湧き方向を返す
//        @discardableResult
//        private func getEnemyAppearId(random: Int64, mEnemyAppearId: Int) -> Int {
//            var id = mEnemyAppearId
//            let mArray: [Int] = [1, 2, 3]
//            var mPtr: Int = 0
//            var w6: Int64 = 3
//            var x6: Int = 3
//            let v5: Int = id
//            let w7: [Int] = mArray
//
//            if !Bool(id & 0x80000000) {
//                var w8: Int64 = w6 - 1
//                while true {
//                    let v17 = w8
//                    let w9 = w7[mPtr]
//                    if w9 < id {
//                        break
//                    }
//                    w6 -= w9 == id ? 1 : 0
//                    if w9 == id {
//                        break
//                    }
//                    w8 = v17 - 1
//                    mPtr += 1
//                    if !Bool(v17) {
//                        break
//                    }
//                }
//            }
//
//            mPtr = 0
//            let x7: [Int] = mArray
//            var x8: Int64 = 0xFFFFFFFF & ((random * w6) >> 0x20)
//
//            while true {
//                let x9: Int = x7[mPtr]
//                let x10: Int64 = max(0, x8 - 1)
//                let x11: Int = x8 == 0 ? x9 : v5
//                let x12: Int = x9 == v5 ? 5 :Int(x8 == 0)
//
//                if x9 != v5 {
//                    x8 = 0xFFFFFFFF & x10
//                    id = x11
//                }
//                if (x12 & 7) != 5 && Bool(x12 & 7) {
//                    break
//                }
//                x6 -= 1
//                mPtr += 1
//                if !Bool(x6) {
//                    return v5
//                }
//            }
//            return id
//        }
    }
    
    public struct WaveUpdateEvent {
        public let index: Int
        public let appearType: AppearType
        public let salmonid: [SalmonType]
    }
    
    public enum AppearType: Int, CaseIterable {
        case none   = -1
        case right  = 1
        case center = 2
        case left   = 3
    }
    
    /// 各タイミングでのアップデート種類
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
