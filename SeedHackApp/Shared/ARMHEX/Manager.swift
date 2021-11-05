//
//  Manager.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/31.
//

import Foundation
import Alamofire
import Combine

final class Converter {
    static var task = Set<AnyCancellable>()
    
    static func convert(_ seed: String, completion: @escaping (Result<String, Error>) -> ()) {
        let url: URL = URL(string: "https://armconverter.com/api/convert")!
        let parameters: Parameters = [
            "asm": ["MOV X0, #0x\(seed.prefix(4))0000", "MOVK X0, #0x\(seed.suffix(4))"].joined(separator: "\n"),
            "arch": ["arm64"]
        ]
        
        print(parameters)
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .publishDecodable(type: ArmToHex.self, queue: DispatchQueue.main, decoder: JSONDecoder())
            .sink(receiveCompletion: { result in
                switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        completion(.failure(error))
                }
            }, receiveValue: { response in
                switch response.result {
                    case .success(let value):
                        completion(.success(value.hex.arm64))
                    case .failure(let error):
                        completion(.failure(error))
                }
            })
            .store(in: &task)
    }
}
