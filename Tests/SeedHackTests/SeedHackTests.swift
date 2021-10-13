import XCTest
@testable import SeedHack

final class SeedHackTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let ocean: Ocean = Ocean(mGameSeed: 0)
        ocean.getWaveInfo()
        
        let eventType: [Ocean.EventType] = [.noevent, .noevent, .goldieseeking]
        let waterLevel: [Ocean.WaterLevel] = [.middle, .middle, .middle]
        XCTAssertEqual(eventType, ocean.mWave.map({ $0.eventType }))
        XCTAssertEqual(waterLevel, ocean.mWave.map({ $0.waterLevel }))
        for wave in ocean.mWave {
            print(wave.mEnemyAppearId)
            print(wave.bossSalmonId)
        }
    }
}
