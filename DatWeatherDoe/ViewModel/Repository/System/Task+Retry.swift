//
//  Task+Retry.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 10/13/25.
//  Copyright © 2025 Inder Dhir. All rights reserved.
//

import Foundation

extension Task where Failure == Error {
    
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    let oneSecond = TimeInterval(1_000_000_000)
                    let delay = UInt64(oneSecond * retryDelay)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    
                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            
            return try await operation()
        }
    }
}
