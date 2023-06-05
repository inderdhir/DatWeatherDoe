//
//  NetworkReachability.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Reachability

final class NetworkReachability {
    
    private let logger: DatWeatherDoeLoggerType
    private var reachability: Reachability?
    private var retryWhenReachable = false
    
    init(
        logger: DatWeatherDoeLoggerType,
        onBecomingReachable: @escaping () -> Void
    ) {
        self.logger = logger
        
        setupWith(callback: onBecomingReachable)
    }

    private func setupWith(callback: @escaping () -> Void) {
        do {
            try createReachability()
            try startReachability()
            updateReachabilityWhenReachable(callback: callback)
            updateReachabilityWhenUnreachable()
        } catch {
            logger.error("Reachability error!")
        }
    }
    
    private func createReachability() throws {
        reachability = try Reachability()
    }
    
    private func startReachability() throws {
        try reachability?.startNotifier()
    }
    
    private func updateReachabilityWhenReachable(callback: @escaping () -> Void) {
        reachability?.whenReachable = { [weak self] _ in
            self?.logger.debug("Reachability status: Reachable")
            
            if self?.retryWhenReachable == true {
                self?.retryWhenReachable = false
                callback()
            }
        }
    }
    
    private func updateReachabilityWhenUnreachable() {
        reachability?.whenUnreachable = { [weak self] _ in
            self?.logger.debug("Reachability status: Unreachable")
            
            self?.retryWhenReachable = true
        }
    }
}
