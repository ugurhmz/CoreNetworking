//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

final class RequestBuilder {
    
    static func build(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.baseURL)?.appendingPathComponent(endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        switch endpoint.task {
        case .requestPlain:
            break
            
        case .requestParameters(let parameters, let encoding):
            try encoding.encode(&request, with: parameters)
            
        case .requestJSONEncodable(let encodable):
            do {
                request.httpBody = try JSONEncoder().encode(encodable)
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                throw NetworkError.encodingFailed
            }
        }
        return request
    }
}
