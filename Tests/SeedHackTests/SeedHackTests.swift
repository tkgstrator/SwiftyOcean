import XCTest
import SeedHack
import Benchmark

final class SeedHackTests: XCTestCase {
    func testBenchmark() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let mAppearIds: [[Int8]] = [
            [2, 2, 1, 3, 1, 2, 2, 2],
            [2, 1, 3, 3, 3, 2, 2, 2]
        ]
        
        let ocean = Ocean(mGameSeed: 1)
        ocean.getWaveDetail()
        let wave = ocean.mWave[0]
        let mAppearId: [Int8] = wave.mWaveUpdateEventArray.map({ $0.appearType.rawValue })
        print(mAppearId)
        XCTAssertEqual(mAppearId, mAppearIds[1])
    }
}
