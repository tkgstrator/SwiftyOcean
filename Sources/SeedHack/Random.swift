//
//  Random.swift
//  
//
//  Created by devonly on 2021/10/13.
//

import Foundation

public class Random {
    private(set) var mSeed1: UInt32 = 0
    private(set) var mSeed2: UInt32 = 0
    private(set) var mSeed3: UInt32 = 0
    private(set) var mSeed4: UInt32 = 0
    
    init() {}
    
    public init(seed: UInt32) {
        self.mSeed1 = (0x6C078965 * (seed   ^ (seed   >> 30)) + 1)
        self.mSeed2 = (0x6C078965 * (mSeed1 ^ (mSeed1 >> 30)) + 2)
        self.mSeed3 = (0x6C078965 * (mSeed2 ^ (mSeed2 >> 30)) + 3)
        self.mSeed4 = (0x6C078965 * (mSeed3 ^ (mSeed3 >> 30)) + 4)
    }
    
    @discardableResult
    public func getU32() -> UInt32 {
        let n = mSeed1 ^ (mSeed1 << 11);

        mSeed1 = mSeed2;
        mSeed2 = mSeed3;
        mSeed3 = mSeed4;
        mSeed4 = n ^ (n >> 8) ^ mSeed4 ^ (mSeed4 >> 19);

        return mSeed4;
    }
}
