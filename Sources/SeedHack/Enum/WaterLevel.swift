//
//  File.swift
//  
//
//  Created by devonly on 2021/10/18.
//

import Foundation

/// 潮位
public enum WaterLevel: UInt32, CaseIterable {
    /// 干潮
    case low    = 0
    /// 通常
    case middle = 1
    /// 満潮
    case high   = 2
    
    /// 重み
    var prob: UInt32 {
        switch self {
            case .low:
                return 1
            case .middle:
                return 3
            case .high:
                return 1
        }
    }
}
