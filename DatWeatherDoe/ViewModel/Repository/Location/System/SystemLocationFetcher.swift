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
    var locationResult: AnyPublisher<Result<CLLocationCoordinate2D, Error>, Never> { get }
    func startUpdatingLocation()
}

final class SystemLocationFetcher: NSObject, SystemLocationFetcherType {
    private let logger: Logger
    private var currentLocation: CLLocationCoordinate2D?
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000
        return locationManager
    }()

    private lazy var currentLocationSerialQueue = DispatchQueue(label: "Location Serial Queue")
    private let locationSubject = PassthroughSubject<Result<CLLocationCoordinate2D, Error>, Never>()
    let locationResult: AnyPublisher<Result<CLLocationCoordinate2D, Error>, Never>

    init(logger: Logger) {
        self.logger = logger
        locationResult = locationSubject.eraseToAnyPublisher()
    }

    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            updateWithMissingLocationServices()
            return
        }

        switch CLLocationManager().authorizationStatus {
        case .notDetermined:
            requestLocationPermission()
        case .authorized:
            requestUpdatedLocation()
        default:
            updateWithDeniedUserLocation()
        }
    }

    private func updateWithMissingLocationServices() {
        logger.error("Location services not enabled")

        locationSubject.send(.failure(WeatherError.locationError))
    }

    private func requestLocationPermission() {
        logger.debug("Location permission not determined")

        locationManager.requestWhenInUseAuthorization()
    }

    private func requestUpdatedLocation() {
        currentLocationSerialQueue.sync { [weak self] in
            _ = self?.sendCachedLocationIfPresent()
        }
        locationManager.startUpdatingLocation()
    }

    private func updateWithDeniedUserLocation() {
        logger.error("Location permission has NOT been granted")

        locationSubject.send(.failure(WeatherError.locationError))
    }

    private func sendCachedLocationIfPresent() -> Bool {
        guard let currentLocation else { return false }

        logger.debug("Sending cached location")

        locationSubject.send(.success(currentLocation))

        return true
    }

    private func updateLocationAfterAuthChange(isAuthorized: Bool) {
        logger.debug("Location permission changed, isAuthorized?: \(isAuthorized)")

        if isAuthorized {
            requestUpdatedLocation()
        } else {
            locationSubject.send(.failure(WeatherError.locationError))
        }
    }

    private func updateLocationAfterError(_ error: Error) {
        logger.error("Getting updated location failed with error \(error.localizedDescription)")

        currentLocationSerialQueue.sync { [weak self] in
            guard let self else { return }

            let isCachedLocationPresent = self.sendCachedLocationIfPresent()
            if !isCachedLocationPresent {
                locationSubject.send(.failure(WeatherError.locationError))
            }
        }
    }

    private func updateLocation(location: CLLocationCoordinate2D?) {
        currentLocationSerialQueue.sync { [weak self] in
            guard let self else { return }

            self.currentLocation = location

            if let currentLocation {
                self.locationSubject.send(.success(currentLocation))
            } else {
                self.logger.error("Getting location failed")

                self.locationSubject.send(.failure(WeatherError.locationError))
            }
        }
    }
}

// MARK: CLLocationManagerDelegate

extension SystemLocationFetcher: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        let isAuthorized = CLLocationManager().authorizationStatus == .authorized
        updateLocationAfterAuthChange(isAuthorized: isAuthorized)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        updateLocationAfterError(error)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations _: [CLLocation]) {
        updateLocation(location: manager.location?.coordinate)
    }
}
