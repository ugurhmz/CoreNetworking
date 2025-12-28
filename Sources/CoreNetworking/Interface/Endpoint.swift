//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public enum RequestTask: Sendable {
    case requestPlain
    case requestParameters(parameters: [String: Sendable],
                           encoding: ParameterEncoding)
    case requestJSONEncodable(encodable: Encodable & Sendable)
    
    //Resim upload vs. için lazım olur
    case requestData(data: Data)
}

public protocol Endpoint: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: RequestTask { get }
    var headers: [String: String]? { get }
}
