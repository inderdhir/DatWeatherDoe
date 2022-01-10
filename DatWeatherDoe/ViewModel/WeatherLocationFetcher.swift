//
//  WeatherLocationFetcher.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

protocol WeatherLocationFetcherDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocationCoordinate2D, isCachedLocation: Bool)
    func didFailLocationUpdate(_ error: Error?)
}

final class WeatherLocationFetcher: NSObject {
    
    weak var delegate: WeatherLocationFetcherDelegate?
    
    private let logger: DatWeatherDoeLoggerType
    private var currentLocation: CLLocationCoordinate2D?
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000
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
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            requestLocationPermission()
        case .authorized:
            requestUpdatedLocation()
        default:
            updateWithDeniedUserLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    private func updateWithMissingLocationServices() {
        logger.logError("Location services not enabled")
        
        delegate?.didFailLocationUpdate(nil)
    }
    
    private func requestLocationPermission() {
        logger.logDebug("Location permission not determined")
        
        if #available(macOS 10.15, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            logger.logError("Location permission not determined on an older MacOS version")
            
            delegate?.didFailLocationUpdate(nil)
        }
    }
    
    private func requestUpdatedLocation() {
        locationManager.startUpdatingLocation()
    }
    
    private func updateWithDeniedUserLocation() {
        logger.logError("Location permission has NOT been granted")
        
        delegate?.didFailLocationUpdate(nil)
    }
}

extension WeatherLocationFetcher: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let isLocationAuthorized = CLLocationManager.authorizationStatus() == .authorized

        logger.logDebug("Location permission changed, isAuthorized?: \(isLocationAuthorized)")
        
        if isLocationAuthorized {
            requestUpdatedLocation()
        } else {
            delegate?.didFailLocationUpdate(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.logError("Getting updated location failed with error \(error.localizedDescription)")
        
        currentLocationSerialQueue.sync { [weak self] in
            if let currentLocation = self?.currentLocation {
                logger.logDebug("Sending last fetched location")
                
                delegate?.didUpdateLocation(currentLocation, isCachedLocation: true)
            } else {
                delegate?.didFailLocationUpdate(error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationSerialQueue.sync {
            currentLocation = manager.location?.coordinate
            
            if let currentLocation = currentLocation {
                delegate?.didUpdateLocation(currentLocation, isCachedLocation: false)
            } else {
                logger.logError("Getting location failed")
                
                delegate?.didFailLocationUpdate(nil)
            }
        }
    }
}
