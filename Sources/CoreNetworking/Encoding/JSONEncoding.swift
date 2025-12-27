//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public struct JSONEncoding: ParameterEncoding {
    public init() {}
    
    public func encode(_ request: inout URLRequest, with parameters: [String : Any]) throws {
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = data
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}
