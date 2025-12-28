//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let interceptor: RequestInterceptor?
    
    // Decoder varsayılan olarak tanımlı ama dışarıdan değiştirilebilir (Dependency Injection)
    public init(session: URLSession = .shared,
                decoder: JSONDecoder = JSONDecoder(),
                interceptor: RequestInterceptor? = nil) {
        self.session = session
        self.decoder = decoder
        self.interceptor = interceptor
    }
    
    // Public metod: Retry sayacını 0 başlatır
    public func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async -> Result<T, NetworkError> {
        return await performRequest(endpoint: endpoint, type: type, retryCount: 0)
    }
    
    private func performRequest<T: Decodable>(endpoint: Endpoint, type: T.Type, retryCount: Int) async -> Result<T, NetworkError> {
        
        do {
            var request = try RequestBuilder.build(from: endpoint)
            if let interceptor = interceptor {
                request = await interceptor.adapt(request)
            }
            
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
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    return .success(decodedResponse)
                } catch {
                    print("Decoding Error: \(error)")
                    return .failure(.decodingFailed)
                }
                
            case 401:
                // Eğer sunucu hala 401 dönüyorsa sonsuz döngüye girme.
                guard retryCount < 2 else {
                    return .failure(.unauthorized)
                }
                
                if let interceptor = interceptor,
                   await interceptor.retry(request, dueTo: .unauthorized) {
                    print("🔄 Token yenilendi, istek tekrar atılıyor... (Deneme: \(retryCount + 1))")
                    return await performRequest(endpoint: endpoint, type: type, retryCount: retryCount + 1)
                }
                return .failure(.unauthorized)
                
            case 500...599:
                return .failure(.serverError(code: httpResponse.statusCode))
                
            default:
                return .failure(.unknown("Status Code: \(httpResponse.statusCode)"))
            }
            
        } catch let error as NetworkError {
            return .failure(error)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .failure(.noInternet)
            case .timedOut:
                return .failure(.timeout)
            case .cancelled:
                 return .failure(.cancelled)
            default:
                return .failure(.unknown(error.localizedDescription))
            }
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
}
