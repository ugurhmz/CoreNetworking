//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest) async -> URLRequest
    func retry(_ request: URLRequest, dueTo error: NetworkError) async -> Bool
}
