//
//  Agent.swift
//  ModernMVVM
//
//  Created by Vadym Bulavin on 2/20/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine
import Alamofire


struct Agent {
    func run<T: Decodable>(_ url: URLComponents) -> AnyPublisher<T, AFError>{
        AF.request(url)
            .publishDecodable(type: T.self)
            .value()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
