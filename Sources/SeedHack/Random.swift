//
//  Random.swift
//  
//
//  Created by devonly on 2021/10/13.
//

import Foundation

final class Random {
    private(set) var mSeed1: Int64 = 0
    private(set) var mSeed2: Int64 = 0
    private(set) var mSeed3: Int64 = 0
    private(set) var mSeed4: Int64 = 0
    
    init() {}
    
    init(seed: Int64) {
        self.mSeed1 = 0xFFFFFFFF & (0x6C078965 * (seed   ^ (seed   >> 30)) + 1)
        self.mSeed2 = 0xFFFFFFFF & (0x6C078965 * (mSeed1 ^ (mSeed1 >> 30)) + 2)
        self.mSeed3 = 0xFFFFFFFF & (0x6C078965 * (mSeed2 ^ (mSeed2 >> 30)) + 3)
        self.mSeed4 = 0xFFFFFFFF & (0x6C078965 * (mSeed3 ^ (mSeed3 >> 30)) + 4)
//        print(String(format:"%08X", mSeed1), String(format:"%08X", mSeed2), String(format:"%08X", mSeed3), String(format:"%08X", mSeed4))
    }
    
    @discardableResult
    func getU32() -> Int64 {
        let n = mSeed1 ^ (0xFFFFFFFF & mSeed1 << 11);

        mSeed1 = mSeed2;
        mSeed2 = mSeed3;
        mSeed3 = mSeed4;
        mSeed4 = n ^ (n >> 8) ^ mSeed4 ^ (mSeed4 >> 19);

        return mSeed4;
    }
}
