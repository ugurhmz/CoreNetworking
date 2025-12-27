//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async -> Result<T, NetworkError>
}
