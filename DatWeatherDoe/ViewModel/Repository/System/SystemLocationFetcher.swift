//
//  SystemLocationFetcher.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import OSLog

protocol SystemLocationFetcherType: AnyObject {
    func getLocation() async throws -> CLLocationCoordinate2D
}

final actor SystemLocationFetcher: NSObject, SystemLocationFetcherType {
    private let logger: Logger
    private var cachedLocation: CLLocationCoordinate2D?
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    private var locationUpdateContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    @MainActor
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000
        return locationManager
    }()

    init(logger: Logger) {
        self.logger = logger
    }

    func getLocation() async throws(WeatherError) -> CLLocationCoordinate2D {
        guard CLLocationManager.locationServicesEnabled() else {
            logger.error("Location services not enabled")

            throw WeatherError.locationError
        }

        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            let isAuthorized = await withCheckedContinuation { continuation in
                logger.debug("Location permission not determined")

                permissionContinuation = continuation

                Task { @MainActor in
                    locationManager.requestWhenInUseAuthorization()
                }
            }

            permissionContinuation = nil

            logger.debug("Location permission changed, isAuthorized?: \(isAuthorized)")

            if isAuthorized {
                return try await requestLatestOrCachedLocation()
            }

            throw WeatherError.locationError

        case .authorized:
            return try await requestLatestOrCachedLocation()

        default:
            logger.error("Location permission has NOT been granted")

            throw WeatherError.locationError
        }
    }

    private func updateCachedLocation(_ location: CLLocationCoordinate2D) {
        cachedLocation = location
    }

    private func requestLatestOrCachedLocation() async throws(WeatherError) -> CLLocationCoordinate2D {
        if let cachedLocation = getCachedLocationIfPresent() {
            return cachedLocation
        }

        do {
            let latestLocation = try await Task.retrying {
                try await self.requestLocation()
            }.value

            return latestLocation
        } catch {
            throw WeatherError.locationError
        }
    }

    private func getCachedLocationIfPresent() -> CLLocationCoordinate2D? {
        if let cachedLocation {
            logger.debug("Sending cached location")

            return cachedLocation
        }

        return nil
    }
    
    private func requestLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            locationUpdateContinuation = continuation
            
            Task { @MainActor in
                locationManager.startUpdatingLocation()
            }
        }
    }
}

// MARK: CLLocationManagerDelegate

extension SystemLocationFetcher: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        let isAuthorized = CLLocationManager().authorizationStatus == .authorized

        Task {
            await permissionContinuation?.resume(returning: isAuthorized)
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        Task {
            await locationUpdateContinuation?.resume(throwing: error)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        let coordinate = manager.location?.coordinate ?? .init(latitude: .zero, longitude: .zero)
        Task {
            await updateCachedLocation(coordinate)
            await locationUpdateContinuation?.resume(returning: coordinate)
        }
    }
}

