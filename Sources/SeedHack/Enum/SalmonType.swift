//
//  File.swift
//  
//
//  Created by devonly on 2021/10/18.
//

import Foundation

/// オオモノシャケの種類
public enum SalmonType: UInt32, CaseIterable {
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
    
    /// 通常オオモノ
    public static var normalCases: [SalmonType] {
        [.shakebomber, .shakecup, .shakeshield, .shakesnake, .shaketower, .shakediver, .shakerocket]
    }
}
