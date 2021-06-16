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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var window: NSWindow!

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private let configManager: ConfigManagerType = ConfigManager()
    private let logger: DatWeatherDoeLoggerType = DatWeatherDoeLogger()
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000 // Only worry about location distance above 3 km
        return locationManager
    }()
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private lazy var currentLocationSerialQueue = DispatchQueue(label: "Location Serial Queue")
    private lazy var weatherRepository: WeatherRepositoryType =
        WeatherRepository(configManager: configManager, logger: logger)
    private lazy var networkErrorString = NSLocalizedString("Network Error", comment: "Network error when fetching weather")
    private lazy var locationErrorString = NSLocalizedString("Location Error", comment: "Location error when fetching weather")
    private lazy var latLongErrorString = NSLocalizedString("Lat/Long Error", comment: "Lat/Long error when fetching weather")
    private lazy var zipCodeErrorString = NSLocalizedString("Zip Code Error", comment: "Zip Code error when fetching weather")
    private lazy var unknownString = NSLocalizedString("Unknown", comment: "Unknown location")
    private var weatherTimer: Timer?
    private var currentLocation: CLLocationCoordinate2D?
    private var eventMonitor: EventMonitor?
    private var reachability: Reachability?
    private var retryWhenReachable = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Unknown Location", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Refresh", action: #selector(getWeather), keyEquivalent: "R")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Configure", action: #selector(togglePopover), keyEquivalent: "C")
        menu.addItem(withTitle: "Quit", action: #selector(terminate), keyEquivalent: "q")

        statusItem.menu = menu
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

    @objc func getWeather(_ sender: AnyObject?) {
        switch WeatherSource(rawValue: configManager.weatherSource) {
        case .latLong:
            guard let latLong = configManager.weatherSourceText else {
                DispatchQueue.main.async { [weak self] in
                    self?.statusItem.title = self?.latLongErrorString
                }
                return
            }
            getWeatherViaCoordinates(latLong)
        case .zipCode:
            guard let zipCode = configManager.weatherSourceText else {
                DispatchQueue.main.async { [weak self] in
                    self?.statusItem.title = self?.zipCodeErrorString
                }
                return
            }
            getWeatherViaZipCode(zipCode)
        default:
            currentLocationSerialQueue.sync {
                guard let currentLocation = currentLocation else {
                    locationManager.startUpdatingLocation()
                    return
                }
                getWeatherViaLocation(currentLocation)
            }
        }
    }

    private func getWeatherViaLocation(_ currentLocation: CLLocationCoordinate2D) {
        weatherRepository.getWeather(location: currentLocation, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateUI(data)
            case .failure:
                DispatchQueue.main.async { [weak self] in
                    self?.statusItem.title = self?.networkErrorString
                    self?.statusItem.image = nil
                }
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
                DispatchQueue.main.async { [weak self] in
                    self?.statusItem.title = isLatLongError ? self?.latLongErrorString : self?.networkErrorString
                    self?.statusItem.image = nil
                }
            }
        })
    }

    private func getWeatherViaZipCode(_ zipCode: String) {
        weatherRepository.getWeather(zipCode: zipCode, completion: { [weak self] result in
            switch result {
            case let .success(data):
                self?.updateUI(data)
            case let .failure(error):
                DispatchQueue.main.async { [weak self] in
                    self?.statusItem.title = error == .zipCodeEmpty ? self?.zipCodeErrorString : self?.networkErrorString
                    self?.statusItem.image = nil
                }
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

            self.statusItem.title = data.textualRepresentation
            self.statusItem.menu?.item(at: 0)?.title = data.location ?? self.unknownString

            let image = NSImage(named: data.weatherCondition.rawValue)
            image?.isTemplate = true
            self.statusItem.image = image
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.logError("Getting location failed with error \(error.localizedDescription)")

        DispatchQueue.main.async { [weak self] in
            self?.statusItem.title = self?.locationErrorString
            self?.statusItem.image = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocationSerialQueue.sync {
            currentLocation = manager.location?.coordinate
            guard let currentLocation = currentLocation else {
                logger.logError("Getting location failed")

                DispatchQueue.main.async { [weak self] in
                    self?.statusItem.title = self?.locationErrorString
                    self?.statusItem.image = nil
                }
                return
            }
            getWeatherViaLocation(currentLocation)
        }
    }
}
