//
//  AppDelegate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import CoreLocation
import os
import Reachability
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private let configManager: ConfigManagerType = ConfigManager()
    private let logger: DatWeatherDoeLoggerType = DatWeatherDoeLogger()
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let fullWeatherUrl = URL(string: "https://openweathermap.org/city")
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000 // Only worry about location distance above 3 km
        return locationManager
    }()
    private lazy var currentLocationSerialQueue = DispatchQueue(label: "Location Serial Queue")
    private lazy var weatherRepository: WeatherRepositoryType =
    WeatherRepository(configManager: configManager, logger: logger)
    
    private var weatherTimer: Timer?
    private var currentLocation: CLLocationCoordinate2D?
    private var cityId: Int?
    private var eventMonitor: EventMonitor?
    private var reachability: Reachability?
    private var retryWhenReachable = false
    
    /* Error Strings */
    
    private lazy var networkErrorString =
    NSLocalizedString("Network Error", comment: "Network error when fetching weather")
    private lazy var locationErrorString =
    NSLocalizedString("Location Error", comment: "Location error when fetching weather")
    private lazy var latLongErrorString =
    NSLocalizedString("Lat/Long Error", comment: "Lat/Long error when fetching weather")
    private lazy var zipCodeErrorString =
    NSLocalizedString("Zip Code Error", comment: "Zip Code error when fetching weather")
    private lazy var unknownString = NSLocalizedString("Unknown", comment: "Unknown location")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.menu = createMenu()
        statusItem.button?.action = #selector(togglePopover)
        
        popover.contentViewController = ConfigureViewController(configManager: configManager)
        
        // Close popover if clicked outside the popover
        eventMonitor = EventMonitor(mask: .leftMouseDown) { [weak self] event in
            DispatchQueue.main.async {
                if self?.popover.isShown == true { self?.closePopover(event) }
            }
        }
        eventMonitor?.start()
        
        setupReachability()
        resetWeatherTimer()
    }
    
    private func setupReachability() {
        do {
            reachability = try Reachability()
            try reachability?.startNotifier()
            
            reachability?.whenReachable = { [weak self] _ in
                self?.logger.logDebug("Reachability status: Reachable")
                if self?.retryWhenReachable == true {
                    self?.retryWhenReachable = false
                    self?.resetWeatherTimer()
                }
            }
            reachability?.whenUnreachable = { [weak self] _ in
                self?.logger.logDebug("Reachability status: Unreachable")
                self?.retryWhenReachable = true
            }
        } catch {
            logger.logError("Reachability error!")
        }
    }
    
    private func resetWeatherTimer() {
        weatherTimerSerialQueue.sync {
            weatherTimer?.invalidate()
            weatherTimer = Timer.scheduledTimer(
                timeInterval: configManager.refreshInterval,
                target: self,
                selector: #selector(getWeather),
                userInfo: nil,
                repeats: true
            )
            weatherTimer?.fire()
        }
    }
    
    // MARK: Weather fetching
    
    @objc func seeFullWeather(_ sender: AnyObject?) {
        guard let cityId = cityId,
              let url = fullWeatherUrl?.appendingPathComponent(String(cityId))
        else { return }
        
        NSWorkspace.shared.open(url)
    }
    
    @objc func getWeather(_ sender: AnyObject?) {
        switch WeatherSource(rawValue: configManager.weatherSource) {
        case .latLong:
            guard let latLong = configManager.weatherSourceText else {
                updateUI(title: latLongErrorString, image: nil)
                return
            }
            getWeatherViaCoordinates(latLong)
        case .zipCode:
            guard let zipCode = configManager.weatherSourceText else {
                updateUI(title: zipCodeErrorString, image: nil)
                return
            }
            getWeatherViaZipCode(zipCode)
        default:
            guard CLLocationManager.locationServicesEnabled() else {
                updateUI(title: locationErrorString, image: nil)
                return
            }
            
            guard CLLocationManager.authorizationStatus() == .authorized else {
                logger.logDebug("Location permission has NOT been granted")
                
                if CLLocationManager.authorizationStatus() == .notDetermined {
                    logger.logDebug("Location permission not determined")
                    if #available(macOS 10.15, *) {
                        locationManager.requestWhenInUseAuthorization()
                    } else {
                        logger.logError("Location permission not determined on an older MacOS version")
                    }
                } else {
                    logger.logDebug("Location permission denied")
                    updateUI(title: locationErrorString, image: nil)
                }
                return
            }
            
            getWeatherViaCurrentOrNewLocation()
        }
    }
    
    private func getWeatherViaCurrentOrNewLocation() {
        currentLocationSerialQueue.sync {
            guard let currentLocation = currentLocation else {
                locationManager.startUpdatingLocation()
                return
            }
            getWeatherViaLocation(currentLocation)
        }
    }
    
    private func getWeatherViaLocation(_ currentLocation: CLLocationCoordinate2D) {
        weatherRepository.getWeather(location: currentLocation, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateUI(data)
            case .failure:
                self?.updateUI(title: self?.networkErrorString, image: nil)
            }
        })
    }
    
    private func getWeatherViaCoordinates(_ latLong: String) {
        weatherRepository.getWeather(latLong: latLong, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateUI(data)
            case let .failure(error):
                let isLatLongError = error == .latLongEmpty || error == .latLongIncorrect
                self?.updateUI(
                    title: isLatLongError ? self?.latLongErrorString : self?.networkErrorString,
                    image: nil
                )
            }
        })
    }
    
    private func getWeatherViaZipCode(_ zipCode: String) {
        weatherRepository.getWeather(zipCode: zipCode, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateUI(data)
            case let .failure(error):
                self?.updateUI(
                    title: error == .zipCodeEmpty ? self?.zipCodeErrorString : self?.networkErrorString,
                    image: nil
                )
            }
        })
    }
    
    // MARK: UI
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
            resetWeatherTimer()
        } else {
            showPopover(sender)
        }
    }
    
    // MARK: Menu
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(
            withTitle: NSLocalizedString("Unknown Location", comment: "Unknown weather location"),
            action: nil,
            keyEquivalent: ""
        )
        menu.addItem(.separator())
        menu.addItem(
            withTitle: NSLocalizedString("See Full Weather", comment: "See Full Weather"),
            action: #selector(seeFullWeather),
            keyEquivalent: "F"
        )
        menu.addItem(.separator())
        menu.addItem(
            withTitle: NSLocalizedString("Refresh", comment: "Refresh weather"),
            action: #selector(getWeather),
            keyEquivalent: "R"
        )
        menu.addItem(
            withTitle: NSLocalizedString("Configure", comment: "Configure app"),
            action: #selector(togglePopover),
            keyEquivalent: "C"
        )
        menu.addItem(
            withTitle: NSLocalizedString("Quit", comment: "Quit app"),
            action: #selector(terminate),
            keyEquivalent: "q"
        )
        return menu
    }
    
    /// Popover stuff for listening for clicks outside the configure window
    private func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        eventMonitor?.start()
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    @objc func terminate() { NSApp.terminate(self) }
    
    private func updateUI(_ data: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.cityId = data.cityId
            self.statusItem.title = data.textualRepresentation
            self.statusItem.menu?.item(at: 0)?.title = data.location ?? self.unknownString
            
            let image = data.weatherCondition.image
            image?.isTemplate = true
            self.statusItem.image = image
        }
    }
    
    private func updateUI(title: String?, image: NSImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.title = title
            self?.statusItem.image = image
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        logger.logDebug("Location permission changed")
        
        guard CLLocationManager.authorizationStatus() == .authorized else {
            updateUI(title: locationErrorString, image: nil)
            return
        }
        getWeatherViaCurrentOrNewLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.logError("Getting location failed with error \(error.localizedDescription)")
        
        guard let currentLocation = currentLocation else {
            updateUI(title: locationErrorString, image: nil)
            return
        }
        
        logger.logDebug("Using last fetched location to get weather")
        
        currentLocationSerialQueue.sync {
            getWeatherViaLocation(currentLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationSerialQueue.sync {
            currentLocation = manager.location?.coordinate
            guard let currentLocation = currentLocation else {
                logger.logError("Getting location failed")
                updateUI(title: locationErrorString, image: nil)
                return
            }
            getWeatherViaLocation(currentLocation)
        }
    }
}
