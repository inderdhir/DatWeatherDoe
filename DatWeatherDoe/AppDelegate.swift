//
//  AppDelegate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import CoreLocation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var window: NSWindow!

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let locationManager = CLLocationManager()
    private let locationTimerInterval = TimeInterval(900)
    private let popover = NSPopover()
    private var defaultsChanged = false
    private var locationTimer: Timer?
    private var weatherTimer: Timer?
    private var currentLocation: CLLocationCoordinate2D?
    private var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000 // Only worry about location distance above 3 km
        locationTimer = createLocationTimer()

        let menu = NSMenu()
        menu.addItem(withTitle: "Unknown Location", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Refresh", action: #selector(getWeather), keyEquivalent: "R")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Configure", action: #selector(togglePopover), keyEquivalent: "C")
        menu.addItem(withTitle: "Quit", action: #selector(terminate), keyEquivalent: "q")

        statusItem.menu = menu
        statusItem.button?.action = #selector(togglePopover)

        popover.contentViewController = ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)

        resetWeatherTimer()

        // Close popover if clicked outside the popover
        eventMonitor = EventMonitor(mask: .leftMouseDown) { [weak self] event in
            if self?.popover.isShown == true { self?.closePopover(event) }
        }
        eventMonitor?.start()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    @objc func getWeather(_ sender: AnyObject?) {
        DefaultsManager.shared.usingLocation ? getWeatherViaLocation() : getWeatherViaZipCodeOrLatLong()
    }

    func createLocationTimer() -> Timer {
        return Timer.scheduledTimer(
            withTimeInterval: locationTimerInterval,
            repeats: true,
            block: { [weak self] _ in self?.getLocation() }
        )
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            defaultsChanged = true
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    @objc func defaultsDidChange(_ sender: AnyObject?) {
        if defaultsChanged {
            defaultsChanged = false
            resetWeatherTimer()
        }
    }

    @objc func terminate() { NSApp.terminate(self) }

    private func resetWeatherTimer() {
        weatherTimer?.invalidate()
        weatherTimer = Timer.scheduledTimer(
            timeInterval: DefaultsManager.shared.refreshInterval,
            target: self,
            selector: #selector(getWeather),
            userInfo: nil, repeats: true
        )
        weatherTimer?.fire()
    }

    private func getWeatherViaZipCodeOrLatLong() {
        WeatherService.shared.getWeather(
            zipCode: DefaultsManager.shared.zipCode,
            latLong: DefaultsManager.shared.latLong
        ) { [weak self] temperature, location, image in
            self?.updateUI(temperature: temperature, location: location, image: image)
        }
    }

    private func getWeatherViaLocation() {
        if let currentLocation = currentLocation {
            WeatherService.shared.getWeather(location: currentLocation) { [weak self] temperature, location, image in
                self?.updateUI(temperature: temperature, location: location, image: image)
            }
        } else {
            getLocation()
        }
    }

    private func updateUI(temperature: String?, location: String?, image: NSImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.title = temperature
            self?.statusItem.menu?.item(at: 0)?.title = location ?? "Unknown"
            self?.statusItem.image = image
        }
    }

    private func getLocation() { locationManager.startUpdatingLocation() }

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

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DefaultsManager.shared.usingLocation = false
        locationTimer?.invalidate()
        getWeatherViaZipCodeOrLatLong()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
        getWeatherViaLocation()
    }
}
