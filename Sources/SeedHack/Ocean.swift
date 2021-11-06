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
    public private(set) var mWave: [Wave] = Array<Wave>()
    /// WAVE情報更新タイミング配列
    private static let mWaveArray: [[UpdateType]] = [
        [2, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0].compactMap({ UpdateType(rawValue: $0) })
    ]
    static let eventTypes: [EventType] = [.noevent, .rush, .goldieseeking, .griller, .fog, .mothership, .cohockcharge]
    static let waterLevels: [WaterLevel] = [.low, .middle, .high]
    
    public init(mGameSeed: UInt32) {
        self.mGameSeed = mGameSeed
        // 乱数生成器を初期化
        super.init(seed: mGameSeed)
        self.mWave = getWaveInfo()
    }
    
    deinit {}
    
    public func getWaveDetail() {
        self.mWave[0].getWaveArray(mWaveNum: 0)
//        self.mWave[1].getWaveArray(mWaveNum: 1)
//        self.mWave[2].getWaveArray(mWaveNum: 2)
    }
    
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
            super.init(seed: mWaveSeed)
        }
        
        public var mWaveSeed: UInt32 = 0
        public var mWaveUpdateEventArray: [WaveUpdateEvent] = []
        public var mGeyserArray: [GeyserPosition] = []
        public var eventType: EventType
        public var waterLevel: WaterLevel
        
        public func getWaveArray(mWaveNum: Int) {
            // イベント内容で分岐
            switch eventType {
                case .noevent, .cohockcharge, .fog:
                    mWaveUpdateEventArray = getEnemyArray(mWaveNum: mWaveNum)
                case .rush:
                    break
                case .goldieseeking:
                    mGeyserArray = getGeyserArray(.shakeride, waterLevel: waterLevel)
                case .griller:
                    break
                case .mothership:
                    break
            }
        }
        
        private func getEnemyArray(mWaveNum: Int) -> [WaveUpdateEvent] {
            let mWaveArray: [UpdateType] = Ocean.mWaveArray[mWaveNum]
            let rnd: Random = Random(seed: self.mWaveSeed)
            rnd.getU32()

            var mWaveEventArray: [WaveUpdateEvent] = []
            var mBossArray: [SalmonType] = []
            var mEnemyAppearId: [AppearType] = [.none]

            for type in mWaveArray {
                guard let mLastEnemyAppearId = mEnemyAppearId.last else { return [] }
                switch type {
                    case .update:
                        // 一回無駄に消化
                        let appearId: AppearType = getEnemyAppearId(random: rnd.getU32(), lastAppearId: mLastEnemyAppearId)
                        mEnemyAppearId.append(appearId)
                        break
                    case .change:
                        let appearId: AppearType = getEnemyAppearId(random: rnd.getU32(), lastAppearId: mLastEnemyAppearId)
                        if !mBossArray.isEmpty {
                            mWaveEventArray.append(WaveUpdateEvent(index: mWaveEventArray.count, appearType: mLastEnemyAppearId, salmonid: mBossArray))
                            mBossArray.removeAll()
                        }
                        mEnemyAppearId.append(appearId)
                    case .appear:
                        switch eventType {
                            case .fog:
                                if (mWaveEventArray.flatMap({ $0.salmonid }).count + mBossArray.count + 1) % 5 == 0 {
                                    rnd.getU32()
                                    mBossArray.append(.shakegoldie)
                                } else {
                                    mBossArray.append(getEnemyId(mEnemySeed: rnd.getU32()))
                                }
                            default:
                                mBossArray.append(getEnemyId(mEnemySeed: rnd.getU32()))
                        }
                    case .none:
                        break
                }
            }
            return mWaveEventArray
        }

        private func getGeyserArray(_ stage: StageType, waterLevel: WaterLevel) -> [GeyserPosition] {
            let rnd: Random = Random(seed: mWaveSeed)
            // 潮位とステージに合わせた配列を読み込む
            var geyser: [GeyserType] = waterLevel == .middle ? stage.middle : stage.high
            var position: [GeyserPosition] = []

            for _ in 0 ... 15 {
                for sel in (1 ... (geyser.count - 1)).reversed() {
                    let index: Int64 = (Int64(rnd.getU32()) &* Int64(sel + 1)) >> 0x20
                    geyser.swapAt(Int(sel), Int(index))
                }
                guard let firstGeyser = geyser.first else { return [] }

                if firstGeyser.mFlag {
                    let index: Int64 = (Int64(rnd.getU32()) &* Int64(firstGeyser.mDest.count)) >> 0x20
                    position.append(GeyserPosition(succ: firstGeyser.mSucc, dest: firstGeyser.mDest[Int(index)]))
                } else {
                    position.append(GeyserPosition(succ: firstGeyser.mSucc, dest: firstGeyser.mDest.first ?? 0))
                }
            }
            return position
        }

        /// 出現するオオモノシャケの種類を返す
        private func getEnemyId(mEnemySeed: UInt32) -> SalmonType {
            let rnd: Random = Random(seed: mEnemySeed)
            let shakeTypes: [SalmonType] = [.shakebomber, .shakecup, .shakeshield, .shakesnake, .shaketower, .shakediver, .shakerocket]
            var mRareId: SalmonType = .shakebomber

            for salmonId in shakeTypes {
                if !Bool((UInt64(rnd.getU32()) * UInt64((salmonId.rawValue + 1))) >> 0x20) {
                    mRareId = salmonId
                }
            }
            return mRareId
        }

        /// シャケが出現する湧き方向を返す
        @discardableResult
        private func getEnemyAppearId(random: UInt32, lastAppearId: AppearType) -> AppearType {
            // 前回の湧き方向が1なら2、それ以外なら3
            let w6: UInt8 = lastAppearId == .right ? 2 : 3
            // 前回の湧き方向が1なら0, 1、それ以外なら0, 1, 2のいずれかを返す
            let w8: UInt64 = (UInt64(random) * UInt64(w6)) >> 0x20 + 1
            let x8: AppearType = AppearType(rawValue: UInt8(w8))!

            switch lastAppearId {
                case .none, .left:
                    return AppearType(rawValue: x8.rawValue)!
                case .right:
                    return AppearType(rawValue: x8.rawValue + 1)!
                case .center:
                    switch x8 {
                        case .right, .none:
                            return .right
                        case .center:
                            return .left
                        case .left:
                            return .center
                    }
            }
        }
    }
    
    public struct WaveUpdateEvent {
        public let index: Int
        public let appearType: AppearType
        public let salmonid: [SalmonType]
    }
    
    public enum AppearType: UInt8, CaseIterable {
        /// 0: 初期状態
        case none   = 0
        /// 1: 右湧き
        case right  = 1
        /// 2: 中央湧き
        case center = 2
        /// 3: 左湧き
        case left   = 3
    }
    
    /// 各タイミングでのアップデート種類
    public enum UpdateType: UInt8, CaseIterable {
        /// 湧き方向変化
        case change = 0
        /// オオモノ出現
        case appear = 1
        /// 乱数のみアップデート
        case update = 2
        /// なにもしない
        case none   = 3
    }
    

}

extension Int8 {
//    static func &(left: UInt8, right: UInt8) -> Bool {
//        left & right == 0
//    }
    
    static func == (left: Int8, right: Int8) -> Int8 {
        left == right ? 1 : 0
    }
    
    static prefix func !(left: Int8) -> Bool {
        left == 0
    }
}

extension UInt64 {
    static func == (left: UInt64, right: UInt64) -> Int8 {
        left == right ? 1 : 0
    }
    
}

extension Bool {
    init(_ value: UInt64) {
        self.init(value != 0)
    }
}
