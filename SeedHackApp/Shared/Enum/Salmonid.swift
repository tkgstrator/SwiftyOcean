//
//  Salmonid.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import Foundation
import SwiftUI
import SeedHack

enum SalmonidType: Int, CaseIterable {
    public enum Package {
        public static let namespace = "Salmonid"
        public static let version = "1.0.0"
    }
    
    case goldie     = 3
    case steelhead  = 6
    case flyfish    = 9
    case scrapper   = 12
    case steeleel   = 13
    case tower      = 14
    case maws       = 15
    case griller    = 16
    case drizzler   = 19

    public var imageName: String {
        "\(Package.namespace)/\(rawValue)"
    }
    
    var name: String {
        switch self {
        case .goldie:
            return "Goldie"
        case .steelhead:
            return "Steelhead"
        case .flyfish:
            return "Flyfish"
        case .scrapper:
            return "Scrapper"
        case .steeleel:
            return "Steel Eel"
        case .tower:
            return "Tower"
        case .maws:
            return "Maws"
        case .griller:
            return "Griller"
        case .drizzler:
            return "Drizzler"
        }
    }
}

extension Image {
    private init(_ symbol: SalmonidType) {
        self.init(symbol.imageName, bundle: .main)
    }
    
    init(_ symbol: SalmonType) {
        self.init(SalmonidType(rawValue: Int(symbol.salmonid))!)
    }
}
