//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public protocol ParameterEncoding: Sendable {
    func encode(_ request: inout URLRequest, with parameters: [String: Any]) throws
}
