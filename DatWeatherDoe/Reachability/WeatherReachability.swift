//
//  WeatherReachability.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import OSLog
import Reachability

final class NetworkReachability {
    private let logger: Logger
    private var reachability: Reachability?
    private var retryWhenReachable = false

    init(
        logger: Logger,
        onBecomingReachable: @escaping () -> Void
    ) {
        self.logger = logger

        setupWith(callback: onBecomingReachable)
    }

    private func setupWith(callback: @escaping () -> Void) {
        do {
            reachability = try Reachability()
            try reachability?.startNotifier()
            updateReachabilityWhenReachable(callback: callback)
            updateReachabilityWhenUnreachable()
        } catch {
            logger.error("Reachability error!")
        }
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
