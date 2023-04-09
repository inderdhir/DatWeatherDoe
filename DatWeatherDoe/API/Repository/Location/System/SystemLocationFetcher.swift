//
//  WeatherLocationFetcher.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

protocol SystemLocationFetcherDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocationCoordinate2D, isCachedLocation: Bool)
    func didFailLocationUpdate()
}

final class SystemLocationFetcher: NSObject {
    
    weak var delegate: SystemLocationFetcherDelegate?
    
    private let logger: DatWeatherDoeLoggerType
    private var currentLocation: CLLocationCoordinate2D?
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000
        return locationManager
    }()
    private lazy var currentLocationSerialQueue = DispatchQueue(label: "Location Serial Queue")

    init(logger: DatWeatherDoeLoggerType) {
        self.logger = logger
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
        
        delegate?.didFailLocationUpdate()
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
        
        delegate?.didFailLocationUpdate()
    }
    
    private func sendCachedLocationIfPresent() -> Bool {
        guard let currentLocation else { return false }
        
        logger.debug("Sending cached location")

        delegate?.didUpdateLocation(currentLocation, isCachedLocation: true)
        return true
    }
    
    private func updateLocationAfterAuthChange(isAuthorized: Bool) {
        logger.debug("Location permission changed, isAuthorized?: \(isAuthorized)")
        
        if isAuthorized {
            requestUpdatedLocation()
        } else {
            delegate?.didFailLocationUpdate()
        }
    }
    
    private func updateLocationAfterError(error: Error) {
        logger.error("Getting updated location failed with error \(error.localizedDescription)")
        
        currentLocationSerialQueue.sync { [weak self] in
            guard let self else { return }
            
            let isCachedLocationPresent = self.sendCachedLocationIfPresent()
            if !isCachedLocationPresent {
                self.delegate?.didFailLocationUpdate()
            }
        }
    }
    
    private func updateLocation(location: CLLocationCoordinate2D?) {
        currentLocationSerialQueue.sync {
            currentLocation = location
            
            if let currentLocation {
                delegate?.didUpdateLocation(currentLocation, isCachedLocation: false)
            } else {
                logger.error("Getting location failed")
                
                delegate?.didFailLocationUpdate()
            }
        }
    }
}

// MARK: CLLocationManagerDelegate

extension SystemLocationFetcher: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let isAuthorized = CLLocationManager().authorizationStatus == .authorized
        updateLocationAfterAuthChange(isAuthorized: isAuthorized)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationAfterError(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation(location: manager.location?.coordinate)
    }
}
