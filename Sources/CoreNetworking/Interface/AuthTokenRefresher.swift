//
//  File.swift
//  CoreNetworking
//
//  Created by rico on 27.12.2025.
//

import Foundation

public actor AuthTokenRefresher {
    
    public static let shared = AuthTokenRefresher()
    private var refreshTask: Task<Bool, Never>?
    private init() {}
    
    public func refresh(action: @escaping @Sendable () async -> Bool) async -> Bool {
        
        if let handle = refreshTask {
            return await handle.value
        }
        
        let task = Task { () -> Bool in
            return await action()
        }
        
        self.refreshTask = task
        
        let result = await task.value
        self.refreshTask = nil
        
        return result
    }
}
