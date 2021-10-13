//
//  SystemImage.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import Foundation
import SwiftUI

enum SystemImage: String, CaseIterable {
    public enum Package {
        public static let namespace = "System"
        public static let version = "1.0.0"
    }
    
    case search     = "magnifyingglass"
    case analyze    = "pencil"
}

extension Image {
    init(_ symbol: SystemImage) {
        self.init(systemName: symbol.rawValue)
    }
}
