import XCTest
import SeedHack
import Benchmark

final class SeedHackTests: XCTestCase {
    func testBenchmark() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let mAppearIds: [[UInt8]] = [
            [2, 2, 1, 3, 1, 2, 2, 2],
            [2, 1, 3, 3, 3, 2, 2, 2],
            [1, 2, 3, 1, 2, 1, 3, 2],
            [2, 1, 3, 3, 1, 2, 3, 2], // ラッシュ
            [3, 1, 3, 1, 2, 1, 2, 1],
            [3, 2, 1, 2, 3, 3, 2, 3],
            [2, 2, 1, 3, 3, 2, 2, 1],
            [3, 2, 2, 1, 2, 2, 3, 3],
            [3, 3, 1, 3, 1, 2, 3, 3],
            [3, 3, 3, 2, 2, 3, 2, 1],
            [3, 3, 2, 3, 3, 1, 3, 1],
            [2, 3, 3, 1, 3, 1, 3, 1],
            [3, 1, 2, 1, 2, 1, 3, 1],
            [2, 1, 2, 1, 3, 1, 2, 1], // グリル
            [1, 2, 2, 3, 1, 3, 1, 3],
            [3, 3, 2, 1, 3, 3, 3, 3]
        ]
        
        for mGameSeed in UInt32(0) ..< UInt32(mAppearIds.count) {
            let ocean = Ocean(mGameSeed: mGameSeed)
            ocean.getWaveDetail()
            
            let wave = ocean.mWave[0]
            let mAppearId: [UInt8] = wave.mWaveUpdateEventArray.map({ $0.appearType.rawValue })
            print(mAppearId)
            XCTAssertEqual(mAppearId, mAppearIds[Int(mGameSeed)])
        }
    }
}
