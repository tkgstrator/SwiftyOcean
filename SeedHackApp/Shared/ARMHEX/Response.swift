//
//  Response.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/31.
//

import Foundation
import Alamofire
import SwiftyJSON

struct ArmToHex: Codable {
    let hex: Hex
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.hex = try container.decode(Hex.self, forKey: .hex)
    }
    
    struct Hex: Codable {
        let arm64: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let arm64 = try container.decode([ArrayValue].self, forKey: .arm64).last {
                switch arm64 {
                    case .bool(_):
                        let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "This is not ARM64")
                        throw DecodingError.dataCorrupted(context)
                    case .string(let value):
                        self.arm64 = value.replacingOccurrences(of: "\n", with: "")
                }
            } else {
                let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "No context of ARM64")
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
    
    enum ArrayValue: Codable {
        case bool(Bool)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let value = try? container.decode(Bool.self) {
                self = .bool(value)
            } else if let value = try? container.decode(String.self) {
                self = .string(value)
            } else {
                let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown type")
                throw DecodingError.dataCorrupted(context)
            }
        }
    }
}
