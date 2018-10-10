//
//  AppDelegate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import CoreLocation
import SwiftyUserDefaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var window: NSWindow!

    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)
    private let weatherService = WeatherService()
    private let locationManager = CLLocationManager()
    private let locationTimerInterval = TimeInterval(900)
    private var locationTimer: Timer?

    private var firstTimeLocationUse = false
    private var weatherTimer: Timer?
    private var currentTempString: String?
    private var currentIconString: String?
    private var currentImageData: NSImage?
    private var currentLocation: CLLocationCoordinate2D?
    private var eventMonitor: EventMonitor?
    private let popover = NSPopover()

    var zipCode: String?
    var refreshInterval: TimeInterval?
    var unit: String?
    var locationUsed = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Location
        firstTimeLocationUse = true
        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000 // Only worry about location distance above 3 km

        locationTimer = createLocationTimer()

        // Defaults
        zipCode = Defaults[.zipCode]
        refreshInterval = Defaults[.refreshInterval]
        unit = Defaults[.unit]
        locationUsed = Defaults[.usingLocation]

        let menu = NSMenu()
        menu.addItem(withTitle: "Refresh", action: #selector(getWeather), keyEquivalent: "R")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Configure", action: #selector(togglePopover), keyEquivalent: "C")
        menu.addItem(withTitle: "Quit", action: #selector(terminate), keyEquivalent: "q")

        statusItem.menu = menu
        statusItem.button?.action = #selector(togglePopover)

        popover.contentViewController =
            ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)

        // Weather Timer
        weatherTimer = Timer.scheduledTimer(timeInterval: refreshInterval!, target: self,
                                                 selector: #selector(getWeather),
                                                 userInfo: nil, repeats: true)
        weatherTimer?.fire()

        // Close popover if clicked outside the popover
        eventMonitor = EventMonitor(mask: .leftMouseDown) { [weak self] event in
            if self?.popover.isShown == true { self?.closePopover(event) }
        }
        eventMonitor?.start()
    }

    @objc func getWeather(_ sender: AnyObject?) {
        locationUsed ? getWeatherViaLocation() : getWeatherViaZipCode()
    }

    func getLocation() {
        locationManager.startUpdatingLocation()
    }

    func getWeatherViaZipCode() {
        if let zipCode = zipCode, let unit = unit {
            weatherService.getWeather(zipCode: zipCode, unit: unit)
            { [weak self] (currentTempString: String, iconString: String) in
                self?.updateWeather(currentTempString)
                self?.updateIcon(iconString)
                self?.updateUI()
            }
        }
    }

    func getWeatherViaLocation() {
        if firstTimeLocationUse {
            getLocation()
        } else if let location = currentLocation, let unit = unit {
            weatherService.getWeather(location: location, unit: unit)
            { [weak self] (currentTempString: String, iconString: String) in
                self?.updateWeather(currentTempString)
                self?.updateIcon(iconString)
                self?.updateUI()
            }
        }
    }

    func createLocationTimer() -> Timer {
        return Timer.scheduledTimer(
            withTimeInterval: locationTimerInterval,
            repeats: true,
            block: { [weak self] _ in self?.getLocation() }
        )
    }

    func updateIcon(_ iconString: String) {
        currentImageData = NSImage(named: iconString)
    }

    func updateWeather(_ currentTempString: String) {
        self.currentTempString = currentTempString
    }

    func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.statusItem.image = strongSelf.currentImageData
            strongSelf.statusItem.title = strongSelf.currentTempString
        }
    }

    /* Popover stuff for listening for clicks outside the configure window */
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

    @objc func togglePopover(_ sender: AnyObject?) {
        popover.isShown ? closePopover(sender) : showPopover(sender)
    }

    @objc func terminate() { NSApp.terminate(self) }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        getWeatherViaZipCode()
        locationUsed = false
        locationTimer?.invalidate()

        // Remember location toggle
        Defaults[.usingLocation] = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            currentLocation = location.coordinate

            if firstTimeLocationUse {
                firstTimeLocationUse = false
                getWeatherViaLocation()
            }

            // Remember location toggle
            Defaults[.usingLocation] = true
        }
    }
}
