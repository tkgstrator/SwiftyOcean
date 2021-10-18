//
//  File.swift
//  
//
//  Created by devonly on 2021/10/18.
//

import Foundation

/// イベントの種類
public enum EventType: UInt32, CaseIterable {
    case noevent        = 0
    case rush           = 1
    case goldieseeking  = 2
    case griller        = 3
    case mothership     = 4
    case fog            = 5
    case cohockcharge   = 6
    
    /// 重み
    var prob: UInt32 {
        switch self {
            case .noevent:
                return 18
            default:
                return 1
        }
    }
}
