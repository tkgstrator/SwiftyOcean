import XCTest
import SeedHack
import Benchmark

final class SeedHackTests: XCTestCase {
    func testBenchmark() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        benchmark("Benchmark") {
            for mGameSeed in Range(0x00000000 ... 0x00100000) {
                let _ = Ocean(mGameSeed: Int32(mGameSeed))
            }
        }
        Benchmark.main()
    }
}
