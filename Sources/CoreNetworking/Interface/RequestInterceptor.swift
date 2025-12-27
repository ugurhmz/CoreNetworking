//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public protocol RequestInterceptor {
    func adapt(_ reuqest: URLRequest) async -> URLRequest // İstek sunucuya gitmeden hemen önce çalışır (Token eklemek için)
    func retry(_ request: URLRequest, dueTo error: NetworkError) async -> Bool // Hata alındığında çalışır (Token yenileyip tekrar denemek için)
}
