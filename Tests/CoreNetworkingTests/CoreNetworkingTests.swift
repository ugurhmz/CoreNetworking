//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import XCTest
@testable import CoreNetworking

final class CoreNetworkingTests: XCTestCase {
    
    var networkClient: NetworkClient!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        
        // 1. Mock Protokolü Session'a tanıtıyoruz
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        
        session = URLSession(configuration: config)
        networkClient = NetworkClient(session: session)
    }
    
    override func tearDown() {
        networkClient = nil
        session = nil
        super.tearDown()
    }
    
    func test_successful_request_returns_user() async throws {
        let jsonString = """
        {
            "id": 1,
            "name": "UGur",
            "email": "ugurhmz@test.com"
        }
        """
        
        guard let mockData = jsonString.data(using: .utf8) else {
            XCTFail("JSON dataya çevrilemedi")
            return
        }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, mockData)
        }
        
        let result = await networkClient.request(TestEndpoint.userProfile, type: User.self)
        
        switch result {
        case .success(let user):
            XCTAssertEqual(user.name, "UGur")
            XCTAssertEqual(user.email, "ugurhmz@test.com")
            XCTAssertEqual(user.id, 1)
        case .failure(let error):
            XCTFail("Başarılı olması gerekiyordu, hata : \(error)")
        }
    }
    
    func test_404_error_returns_unknown_error() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 404,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, nil)
        }
        let result = await networkClient.request(TestEndpoint.userProfile, type: User.self)
        
        switch result {
        case .success:
            XCTFail("404 dönen istek başarılı olmamalıydı.")
        case .failure(let error):
            if case .unknown(let message) = error {
                XCTAssertTrue(message.contains("404"))
            } else {
                XCTFail("Beklenen hata tipi gelmedi: \(error)")
            }
        }
    }
}

// MARK: -
struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

enum TestEndpoint: Endpoint {
    case userProfile
    
    var baseURL: String { "https://api.test.com" }
    var path: String { "/users/1" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .requestPlain }
    var headers: [String : String]? { nil }
}
