//
//  Ocean.swift
//  
//
//  Created by devonly on 2021/10/13.
//

import Foundation

public final class Ocean: ObservableObject {
    /// 初期ゲームシード
    private(set) var mGameSeed: Int64
    /// WAVE情報
    @Published public var mWave: [Wave] = []
    /// WAVE情報更新タイミング配列
    private let mWaveArray: [[UpdateType]] = [
        [2, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 3, 3].compactMap({ UpdateType(rawValue: $0) }),
        [2, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0].compactMap({ UpdateType(rawValue: $0) })
    ]
    
    public init(mGameSeed: Int64) {
        self.mGameSeed = mGameSeed
        let rnd: Random = Random(seed: mGameSeed)
        rnd.getU32()
        self.mWave = [
            Wave(0, mGameSeed, mWaveArray[0]),
            Wave(1, rnd.getU32(), mWaveArray[1]),
            Wave(2, rnd.getU32(), mWaveArray[2])
        ]
    }
    
    convenience public init(mGameSeed: Int32) {
        self.init(mGameSeed: Int64(mGameSeed))
    }
    
    convenience public init(mGameSeed: Int) {
        self.init(mGameSeed: Int64(mGameSeed))
    }
    
    public func setGameSeed(mGameSeed: Int64) {
        self.mGameSeed = mGameSeed
        let rnd: Random = Random(seed: mGameSeed)
        rnd.getU32()
        self.mWave = [
            Wave(0, mGameSeed,    mWaveArray[0]),
            Wave(1, rnd.getU32(), mWaveArray[1]),
            Wave(2, rnd.getU32(), mWaveArray[2])
        ]
    }
    
    public func setGameSeed(mGameSeed: Int32) {
        setGameSeed(mGameSeed: Int64(mGameSeed))
    }
    
    public func getWaveInfo() {
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
        objectWillChange.send()
    }
    
    /// WAVE情報を持つクラス
    public class Wave {
        internal init(_ index: Int, _ initialSeed: Int64, _ waveArray: [UpdateType]) {
            self.index = index
            self.mWaveSeed = initialSeed
            self.mWaveArray = waveArray
        }
        
        public let index: Int
        private var mWaveArray: [UpdateType]
        public var mWaveSeed: Int64 = 0
        public var mWaveUpdateEventArray: [WaveUpdateEvent] = []
        public var mGeyserArray: [GeyserPosition] = []
        public var eventType: EventType = .noevent
        public var waterLevel: WaterLevel = .middle
        
        public func getWaveArray() {
            // イベント内容で分岐
            switch eventType {
                case .noevent, .cohockcharge, .fog:
                    mWaveUpdateEventArray = getEnemyArray()
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
        
        private func getEnemyArray() -> [WaveUpdateEvent] {
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
                        getEnemyAppearId(random: rnd.getU32(), mEnemyAppearId: mLastEnemyAppearId)
                    case .change:
                        guard let appearId: AppearType = AppearType(rawValue: getEnemyAppearId(random: rnd.getU32(), mEnemyAppearId: mLastEnemyAppearId)) else { return [] }
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
                    let index: Int64 = (rnd.getU32() * Int64(sel + 1)) >> 0x20
                    geyser.swapAt(Int(sel), Int(index))
                }
                guard let firstGeyser = geyser.first else { return [] }
                
                if firstGeyser.mFlag {
                    let index: Int64 = (rnd.getU32() * Int64(firstGeyser.mDest.count)) >> 0x20
                    position.append(GeyserPosition(succ: firstGeyser.mSucc, dest: firstGeyser.mDest[Int(index)]))
                } else {
                    position.append(GeyserPosition(succ: firstGeyser.mSucc, dest: firstGeyser.mDest.first ?? 0))
                }
            }
            return position
        }
        
        /// 出現するオオモノシャケの種類を返す
        private func getEnemyId(mEnemySeed: Int64) -> SalmonType {
            let rnd: Random = Random(seed: mEnemySeed)
            var mRareId: SalmonType = .shakebomber
            
            for salmonId in SalmonType.normal {
                if !Bool((rnd.getU32() * (salmonId.rawValue + 1)) >> 0x20) {
                    mRareId = salmonId
                }
            }
            return mRareId
        }
        
        /// シャケが出現する湧き方向を返す
        @discardableResult
        private func getEnemyAppearId(random: Int64, mEnemyAppearId: AppearType) -> Int {
            getEnemyAppearId(random: random, mEnemyAppearId: mEnemyAppearId.rawValue)
        }
       
        /// シャケが出現する湧き方向を返す
        @discardableResult
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
    
    /// オオモノシャケの種類
    public enum SalmonType: Int64, CaseIterable {
        case shakegoldie = -1
        case shakebomber = 0
        case shakecup = 1
        case shakeshield = 2
        case shakesnake = 3
        case shaketower = 4
        case shakediver = 5
        case shakedozer = -2
        case shakerocket = 6
        
        /// 重み
        var prob: Int64 { 1 }
        
        /// 通常オオモノ
        public static var normal: [SalmonType] {
            [.shakebomber, .shakecup, .shakeshield, .shakesnake, .shaketower, .shakediver, .shakerocket]
        }
    }
    
    /// 潮位
    public enum WaterLevel: Int, CaseIterable {
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
   
    /// イベントの種類
    public enum EventType: Int, CaseIterable {
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
