//
//  RealmSeed.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/17.
//

import Foundation
import RealmSwift
import SeedHack

final class RealmSeed: Object {
    @Persisted(primaryKey: true) var mGameSeed: String
    @Persisted var eventTypes: RealmSwift.List<EventType>
    @Persisted var waterLevels: RealmSwift.List<WaterLevel>
    @Persisted var bossSalmonids: RealmSwift.List<Int8>
    @Persisted var mWave: String
    @Persisted var mTitle: String?

    convenience init(mGameSeed: String) {
        self.init()
        self.mGameSeed = mGameSeed
        let ocean: Ocean = Ocean(mGameSeed: UInt32(mGameSeed, radix: 16)!)
        self.eventTypes.append(objectsIn: ocean.mWave.map({ $0.eventType }))
        self.waterLevels.append(objectsIn: ocean.mWave.map({ $0.waterLevel }))
        self.mWave = zip(waterLevels, eventTypes).map({ String(format: "%02d", $0.0.rawValue * 10 + $0.1.rawValue) }).joined()
    }
    
    convenience init(mGameSeed: String, memo mTitle: String) {
        self.init(mGameSeed: mGameSeed)
        self.mTitle = mTitle
    }
    
    convenience init(ocean: Ocean) {
        self.init()
        self.mGameSeed = String(format: "%08X", ocean.mGameSeed)
        self.eventTypes.append(objectsIn: ocean.mWave.map({ $0.eventType }))
        self.waterLevels.append(objectsIn: ocean.mWave.map({ $0.waterLevel }))
        self.mWave = zip(waterLevels, eventTypes).map({ String(format: "%02d", $0.0.rawValue * 10 + $0.1.rawValue) }).joined()
    }
}

extension RealmSeed: Identifiable {
    var id: String { mGameSeed }
}

extension WaterLevel: PersistableEnum, RealmCollectionValue {
}

extension EventType: PersistableEnum, RealmCollectionValue {
}

extension SalmonType: PersistableEnum, RealmCollectionValue {
}
