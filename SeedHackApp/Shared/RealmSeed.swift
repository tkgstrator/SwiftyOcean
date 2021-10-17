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
    @Persisted var eventTypes: RealmSwift.List<Ocean.EventType>
    @Persisted var waterLevels: RealmSwift.List<Ocean.WaterLevel>
    @Persisted var bossSalmonids: RealmSwift.List<Int>
    
    convenience init(mGameSeed: String) {
        self.init()
        self.mGameSeed = mGameSeed
        let ocean: Ocean = Ocean(mGameSeed: Int32(mGameSeed, radix: 16)!)
        self.eventTypes.append(objectsIn: ocean.mWave.map({ $0.eventType }))
        self.waterLevels.append(objectsIn: ocean.mWave.map({ $0.waterLevel }))
    }
    
    convenience init(ocean: Ocean) {
        self.init()
        self.mGameSeed = String(format: "%08X", ocean.mGameSeed)
        self.eventTypes.append(objectsIn: ocean.mWave.map({ $0.eventType }))
        self.waterLevels.append(objectsIn: ocean.mWave.map({ $0.waterLevel }))
    }
}

extension Ocean.WaterLevel: PersistableEnum, RealmCollectionValue {
    
}

extension Ocean.EventType: PersistableEnum, RealmCollectionValue {
    
}

extension Ocean.SalmonType: PersistableEnum, RealmCollectionValue {
    
}
