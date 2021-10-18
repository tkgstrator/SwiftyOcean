import XCTest
import SeedHack
import Benchmark

final class SeedHackTests: XCTestCase {
    func testBenchmark() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        benchmark("Initialize Random Number Generator") {
            for mGameSeed in UInt32(0x00000000) ... UInt32(0x000FFFFF) {
                let rnd = Random(seed: mGameSeed)
            }
        }
        Benchmark.main()
    }
}
