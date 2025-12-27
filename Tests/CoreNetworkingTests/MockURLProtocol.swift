//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

class MockURLProtocol: URLProtocol {
    
    private final class MockState: @unchecked Sendable {
        private var handler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
        private let lock = NSLock()
        
        var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))? {
            get {
                lock.lock()
                defer { lock.unlock() }
                return handler
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                handler = newValue
            }
        }
    }
    
    private static let state = MockState()
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))? {
        get { return state.requestHandler }
        set { state.requestHandler = newValue }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler atanmadı!")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}
