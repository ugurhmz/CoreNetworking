//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let interceptor: RequestInterceptor?
    
    public init(session: URLSession = .shared, interceptor: RequestInterceptor? = nil) {
        self.session = session
        self.interceptor = interceptor
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async -> Result<T, NetworkError> {
        
        do {
            var request = try RequestBuilder.build(from: endpoint)
            if let interceptor = interceptor {
                request = await interceptor.adapt(request)
            }
            return try await performRequest(request: request, endpoint: endpoint)
            
        } catch let error as NetworkError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    private func performRequest<T: Decodable>(request: URLRequest, endpoint: Endpoint) async throws -> Result<T, NetworkError> {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                if T.self == EmptyResponse.self {
                    return .success(EmptyResponse() as! T)
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    return .success(decodedResponse)
                } catch {
                    print("Decoding Error: \(error)")
                    return .failure(.decodingFailed)
                }
                
            case 401:
                if let interceptor = interceptor,
                   await interceptor.retry(request, dueTo: .unauthorized) {
                    print("Token yenilendi, istek tekrar atılıyor...")
                    return await self.request(endpoint, type: T.self)
                }
                return .failure(.unauthorized)
                
            case 500...599:
                return .failure(.serverError(code: httpResponse.statusCode))
                
            default:
                return .failure(.unknown("Unexpected Status Code: \(httpResponse.statusCode)"))
            }
            
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .failure(.noInternet)
            case .timedOut:
                return .failure(.timeout)
            default:
                return .failure(.unknown(error.localizedDescription))
            }
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
}
