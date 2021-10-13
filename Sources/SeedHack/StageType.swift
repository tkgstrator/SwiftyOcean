//
//  StageType.swift
//
//
//  Created by devonly on 2021/10/13.
//
import Foundation

public class GeyserType {
    internal init(mFlag: Bool, mSucc: Int, mDest: [Int]) {
        self.mFlag = mFlag
        self.mSucc = mSucc
        self.mDest = mDest
    }
    
    let mFlag: Bool
    let mSucc: Int
    let mDest: [Int]
}

public struct GeyserPosition {
    public let succ: Int
    public let dest: Int
}

public enum StageType: CaseIterable {
    case shakeup
    case shakeship
    case shakehouse
    case shakelift
    case shakeride
    
    var middle: [GeyserType] {
        switch self {
            case .shakeup:
                return Shakeup.middle
            case .shakeship:
                return Shakeship.middle
            case .shakehouse:
                return Shakehouse.middle
            case .shakelift:
                return Shakelift.middle
            case .shakeride:
                return Shakeride.middle
        }
    }
    
    var high: [GeyserType] {
        switch self {
            case .shakeup:
                return Shakeup.high
            case .shakeship:
                return Shakeship.high
            case .shakehouse:
                return Shakehouse.high
            case .shakelift:
                return Shakelift.high
            case .shakeride:
                return Shakeride.high
        }
    }
}


private class Shakeup {
    static let high: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 4, mDest: [7]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [6, 7]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [5]),
        GeyserType(mFlag: true, mSucc: 7, mDest: [8, 5]),
        GeyserType(mFlag: true, mSucc: 8, mDest: [7, 6]),
    ]
    static let middle: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 0, mDest: [5, 6, 3, 2]),
        GeyserType(mFlag: true, mSucc: 1, mDest: [4, 5, 3, 8]),
        GeyserType(mFlag: true, mSucc: 2, mDest: [4, 3, 7, 6]),
        GeyserType(mFlag: true, mSucc: 3, mDest: [2, 0]),
        GeyserType(mFlag: true, mSucc: 4, mDest: [2, 7, 1]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [0, 6, 7, 1]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [5, 2, 0]),
        GeyserType(mFlag: true, mSucc: 7, mDest: [8, 2, 4, 5]),
        GeyserType(mFlag: true, mSucc: 8, mDest: [7, 1, 0]),
    ]
}

private class Shakeship {
    static let high: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 4, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [0]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 7, mDest: [0, 1]),
    ]
    static let middle: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 0, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 1, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 2, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 3, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 4, mDest: [0, 1, 2, 3]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [0, 1, 2, 3]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [0, 1]),
        GeyserType(mFlag: true, mSucc: 7, mDest: [0, 1]),
    ]
}

private class Shakehouse {
    static let high: [GeyserType] = [
        GeyserType(mFlag: false, mSucc: 0, mDest: [7]),
        GeyserType(mFlag: true, mSucc: 1, mDest: [6, 7]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [8, 5]),
        GeyserType(mFlag: true, mSucc: 7, mDest: [8, 5]),
        GeyserType(mFlag: true, mSucc: 8, mDest: [6, 7]),
    ]
    static let middle: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 0, mDest: [2, 4]),
        GeyserType(mFlag: true, mSucc: 1, mDest: [3, 5, 6, 7]),
        GeyserType(mFlag: true, mSucc: 2, mDest: [0, 3, 8, 5]),
        GeyserType(mFlag: true, mSucc: 3, mDest: [6, 1, 8, 2]),
        GeyserType(mFlag: true, mSucc: 4, mDest: [0, 6, 3, 5]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [7, 1, 6, 8]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [3, 8, 5, 1]),
        GeyserType(mFlag: true, mSucc: 7, mDest: [5, 8, 1, 4]),
        GeyserType(mFlag: true, mSucc: 8, mDest: [6, 3, 5, 2]),
    ]
}

private class Shakelift {
    static let high: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 2, mDest: [6, 4]),
        GeyserType(mFlag: true, mSucc: 3, mDest: [5, 6]),
        GeyserType(mFlag: true, mSucc: 4, mDest: [2]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [3]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [3, 2]),
    ]
    static let middle: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 0, mDest: [5, 6, 1, 2]),
        GeyserType(mFlag: true, mSucc: 1, mDest: [0, 4, 3]),
        GeyserType(mFlag: true, mSucc: 2, mDest: [5, 0, 6, 4]),
        GeyserType(mFlag: true, mSucc: 3, mDest: [1, 5, 6]),
        GeyserType(mFlag: true, mSucc: 4, mDest: [1, 2]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [0, 3]),
        GeyserType(mFlag: true, mSucc: 6, mDest: [0, 3, 2]),
    ]
}

private class Shakeride {
    static let high: [GeyserType] = [
        GeyserType(mFlag: false, mSucc: 3, mDest: [6]),
        GeyserType(mFlag: false, mSucc: 4, mDest: [5]),
        GeyserType(mFlag: false, mSucc: 5, mDest: [6]),
        GeyserType(mFlag: false, mSucc: 6, mDest: [5]),
    ]
    static let middle: [GeyserType] = [
        GeyserType(mFlag: true, mSucc: 0, mDest: [4, 3]),
        GeyserType(mFlag: true, mSucc: 1, mDest: [2]),
        GeyserType(mFlag: true, mSucc: 2, mDest: [3, 1, 5]),
        GeyserType(mFlag: true, mSucc: 3, mDest: [0, 2]),
        GeyserType(mFlag: true, mSucc: 4, mDest: [0]),
        GeyserType(mFlag: true, mSucc: 5, mDest: [2]),
        GeyserType(mFlag: false, mSucc: 6, mDest: [1]),
    ]
}
