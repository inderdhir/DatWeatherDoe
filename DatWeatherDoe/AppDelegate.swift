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
    
    private let fullWeatherUrl = URL(string: "https://openweathermap.org/city")
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let popover = NSPopover()
    private let configManager: ConfigManagerType = ConfigManager()
    private let logger: DatWeatherDoeLoggerType = DatWeatherDoeLogger()
    private var viewModel: WeatherViewModel!
    private var cityId: Int?
    private var eventMonitor: EventMonitor?
    private var reachability: Reachability?
    private var retryWhenReachable = false
    private lazy var unknownString = NSLocalizedString("Unknown", comment: "Unknown location")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let appId = fetchWeatherAppId()
    
        viewModel = WeatherViewModel(
            appId: appId,
            errorStrings: ErrorStrings(),
            configManager: configManager,
            logger: logger
        )
        viewModel.delegate = self
        
        statusItem.menu = createMenu()
        statusItem.button?.action = #selector(togglePopover)
        
        popover.contentViewController = ConfigureViewController(configManager: configManager)
        
        eventMonitor = createEventMonitor()
        eventMonitor?.start()
        
        setupReachability()
        resetWeatherTimer()
    }
    
    private func fetchWeatherAppId() -> String {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let appId = plist["OPENWEATHERMAP_APP_ID"] as? String else {
                  fatalError("Unable to find OPENWEATHERMAP_APP_ID in Keys.plist")
              }
        
        return appId
    }
    
    private func createEventMonitor() -> EventMonitor {
        EventMonitor(mask: .leftMouseDown) { [weak self] event in
            // Close popover if clicked outside the popover
            DispatchQueue.main.async {
                if self?.popover.isShown == true {
                    self?.closePopover(event)
                }
            }
        }
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
        viewModel.resetWeatherTimer()
    }
    
    // MARK: Weather fetching
    
    @objc func seeFullWeather(_ sender: AnyObject?) {
        guard let url = constructFullWeatherUrl() else {
            logger.logError("Unable to construct full weather URL")
            
            return
        }
        
        NSWorkspace.shared.open(url)
    }
    
    private func constructFullWeatherUrl() -> URL? {
        if let cityId = cityId,
           let url = fullWeatherUrl?.appendingPathComponent(String(cityId)) {
            return url
        }
        return nil
    }
    
    @objc func getWeather(_ sender: AnyObject?) {
        resetWeatherTimer()
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
    
    private func showPopover(_ sender: AnyObject?) {
        // Popover stuff for listening for clicks outside the configure window
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
    
    private func updateUIWithWeatherData(_ data: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.cityId = data.cityId
            self.statusItem.title = data.textualRepresentation
            self.statusItem.menu?.item(at: 0)?.title = self.getWeatherLocation(data)
            self.statusItem.image = self.getWeatherImage(data)
        }
    }
    
    private func getWeatherLocation(_ data: WeatherData) -> String {
        data.location ?? unknownString
    }
    
    private func getWeatherImage(_ data: WeatherData) -> NSImage? {
        let image = data.weatherCondition.image
        image?.isTemplate = true
        return image
    }
    
    private func updateUIWithError(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.title = error
            self?.statusItem.image = nil
        }
    }
}

extension AppDelegate: WeatherViewModelDelegate {
    func didUpdateWeatherData(_ data: WeatherData) {
        updateUIWithWeatherData(data)
    }
    
    func didFailToUpdateWeatherData(_ error: String) {
        updateUIWithError(error)
    }
}
