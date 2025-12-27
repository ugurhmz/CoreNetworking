//
//  NetworkError.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case encodingFailed
    case decodingFailed
    case noResponse
    case unauthorized
    case noInternet
    case timeout
    case serverError(code: Int)
    case unknown(String)
    
    
    public var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Please check your internet connection."
        case .timeout:
            return "The request timed out."
        case .serverError(let code):
            return "Server error: \(code)"
        case .unauthorized:
            return "Your session has expired."
        case .decodingFailed:
            return "An error occurred while processing the data."
        default:
            return "An error occurred: \(self)"
        }
    }
}
