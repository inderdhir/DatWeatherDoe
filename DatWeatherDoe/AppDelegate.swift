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

    let weatherService = WeatherService()
    let locationManager = CLLocationManager()
    let locationTimerInterval = TimeInterval(900)
    var locationTimer: Timer?
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    var firstTimeLocationUse: Bool = false
    var weatherTimer: Timer?
    var currentTempString: String?
    var currentIconString: String?
    var currentImageData: NSImage?
    var currentLocation: CLLocationCoordinate2D?
    var eventMonitor: EventMonitor?
    let popover = NSPopover()

    var zipCode: String?
    var refreshInterval: TimeInterval?
    var unit: String?
    var locationUsed: Bool = false

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

        // Menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh",
                                action: #selector(getWeather), keyEquivalent: "R"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Configure",
                                action: #selector(togglePopover), keyEquivalent: "C"))
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(terminate), keyEquivalent: "q"))
        statusItem.menu = menu

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
        }
        popover.contentViewController =
            ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)

        // Weather Timer
        weatherTimer = Timer.scheduledTimer(timeInterval: refreshInterval!, target: self,
                                                 selector: self.locationUsed ?
                                                    #selector(getWeatherViaLocation) :
                                                    #selector(getWeatherViaZipCode),
                                                 userInfo: nil, repeats: true)
        weatherTimer?.fire()

        // Event monitor to listen for clicks outside the popover
        eventMonitor = EventMonitor(mask: .leftMouseDown) { [weak self] event in
            guard let strongSelf = self else { return }
            if strongSelf.popover.isShown {
                strongSelf.closePopover(event)
            }
        }
        eventMonitor?.start()
    }

    func getLocation() {
        locationManager.startUpdatingLocation()
    }

    func getWeather(_ sender: AnyObject?) {
        locationUsed ? getWeatherViaLocation() : getWeatherViaZipCode()
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
        return Timer.scheduledTimer(timeInterval: locationTimerInterval, target: self,
                                    selector: #selector(getLocation), userInfo: nil, repeats: true)
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

    func togglePopover(_ sender: AnyObject?) {
        popover.isShown ? closePopover(sender) : showPopover(sender)
    }

    func terminate() {
        NSApp.terminate(self)
    }

    // If user declines location permission
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        getWeatherViaZipCode()
        locationUsed = false
        locationTimer?.invalidate()

        // Remember location toggle
        Defaults[.usingLocation] = false
    }

    // MARK: CLLocationManagerDelegate
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
