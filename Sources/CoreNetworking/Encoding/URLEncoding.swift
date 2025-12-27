//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public struct URLEncoding: ParameterEncoding {
    public init() {}
    
    public func encode(_ request: inout URLRequest, with parameters: [String: Any]) throws {
        guard let url = request.url else { throw NetworkError.invalidURL }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
            
            request.url = urlComponents.url
        }
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
