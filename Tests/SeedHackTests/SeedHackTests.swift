import XCTest
@testable import SeedHack

final class SeedHackTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let ocean: Ocean = Ocean(mGameSeed: 0)
        ocean.getWaveInfo()
        
        var seeds: [Int32] = []
        for mGameSeed in 0 ... Int32.max {
            let mGameSeed: Int32 = Int32(mGameSeed)
            ocean.setGameSeed(mGameSeed: mGameSeed)
            ocean.getWaveInfo()
            if ocean.mWave.map({ $0.eventType }) == [.goldieseeking, .griller, .goldieseeking] && ocean.mWave.map({ $0.waterLevel }) == Array(repeating: .high, count: 3) {
                seeds.append(mGameSeed)
                print(String(format: "%08X: %08X %.5f\r", mGameSeed, seeds.count, Double(seeds.count) / Double(mGameSeed + 1)))
            }
        }
//
//        let eventType: [Ocean.EventType] = [.noevent, .noevent, .goldieseeking]
//        let waterLevel: [Ocean.WaterLevel] = [.middle, .middle, .middle]
//        XCTAssertEqual(eventType, ocean.mWave.map({ $0.eventType }))
//        XCTAssertEqual(waterLevel, ocean.mWave.map({ $0.waterLevel }))
//        for wave in ocean.mWave {
//            print(wave.mEnemyAppearId)
//            print(wave.bossSalmonId)
//        }
    }
}
