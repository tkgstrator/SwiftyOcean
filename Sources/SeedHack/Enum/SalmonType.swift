//
//  File.swift
//  
//
//  Created by devonly on 2021/10/18.
//

import Foundation

/// オオモノシャケの種類
public enum SalmonType: Int8, CaseIterable {
    case shakebomber    = 0
    case shakecup       = 1
    case shakeshield    = 2
    case shakesnake     = 3
    case shaketower     = 4
    case shakediver     = 5
    case shakerocket    = 6
    case shakegoldie    = 7
    case shakedozer     = 8
    
    /// 重み
    var prob: UInt32 { 1 }
    
    public var salmonid: Int8 {
        switch self {
            case .shakegoldie:
                return 3
            case .shakebomber:
                return 6
            case .shakecup:
                return 9
            case .shakeshield:
                return 12
            case .shakesnake:
                return 13
            case .shaketower:
                return 14
            case .shakediver:
                return 15
            case .shakedozer:
                return 16
            case .shakerocket:
                return 19
        }
    }
}
