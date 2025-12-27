//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public final class AuthenticationInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenProvider: @Sendable () -> String?
    private let refreshAction: @Sendable () async -> Bool
    
    public init(tokenProvider: @escaping @Sendable () -> String?,
                refreshAction: @escaping @Sendable () async -> Bool) {
        self.tokenProvider = tokenProvider
        self.refreshAction = refreshAction
    }
    
    public func adapt(_ request: URLRequest) async -> URLRequest {
        var urlRequest = request
        if let token = tokenProvider() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
    
    public func retry(_ request: URLRequest, dueTo error: NetworkError) async -> Bool {
        guard error == .unauthorized else { return false }
        return await AuthTokenRefresher.shared.refresh(action: refreshAction)
    }
}

/* Not:
 Neden @unchecked Sendable kullandık? Normalde final classlar immutable (değişmez) property'lere sahipse otomatik Sendable olur. Ancak derleyici bazen closure tutan sınıflarda emin olamaz. Biz burada "Merak etme, bu closure'lar zaten @Sendable, thread-safe olduğunu garanti ediyorum" diyerek @unchecked Sendable ile derleyiciyi susturduk.
 */
