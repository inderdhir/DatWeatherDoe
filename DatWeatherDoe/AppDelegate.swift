//
//  AppDelegate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import SnapHTTP
import CoreLocation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let DARK_MODE = "Dark"
    
    let weatherRetriever = WeatherRetriever()
    let locationManager = CLLocationManager()
    let locationTimerInterval = NSTimeInterval(900)
    var locationTimer: NSTimer?
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var firstTimeLocationUse: Bool?
    var weatherTimer: NSTimer?
    
    var currentTempString: String?
    var currentIconString: String?
    var currentImageData: NSImage?
    var currentLocation: CLLocationCoordinate2D?
    let popover = NSPopover()
            
    var zipCode: String?
    var refreshInterval: NSTimeInterval?
    var unit: String?
    var locationUsed: Bool?
    
    var eventMonitor: EventMonitor?
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Check if dark/light mode
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == DARK_MODE {
            weatherRetriever.setDarkMode(true)
        }
        
        // Location
        firstTimeLocationUse = true
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000 // Only worry about location distance above 3 km
        
        self.locationTimer = createLocationTimer()
        
        // Defaults
        self.zipCode = DefaultsChecker.getDefaultZipCode()
        self.refreshInterval = DefaultsChecker.getDefaultRefreshInterval()
        self.unit = DefaultsChecker.getDefaultUnit()
        self.locationUsed = DefaultsChecker.getDefaultLocationUsedToggle()
        
        // Menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(getWeather), keyEquivalent: "R"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Configure", action: #selector(togglePopover), keyEquivalent: "C"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(terminate), keyEquivalent: "q"))
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.action = #selector(togglePopover)
        }
        popover.contentViewController = ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)
        
        // Weather Timer
        if self.locationUsed == true {
            self.weatherTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval!, target: self, selector: #selector(getWeatherViaLocation), userInfo: nil, repeats: true)
            self.locationTimer!.fire()
        }
        else {
            self.weatherTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval!, target: self, selector: #selector(getWeatherViaZipCode), userInfo: nil, repeats: true)
        }
        
        self.weatherTimer!.fire()
        self.weatherTimer!.fire() // Fired twice due to a bug where the icon and temperature don't display properly the first time
        
        // Event monitor to listen for clicks outside the popover
        eventMonitor = EventMonitor(mask: NSEventMask.LeftMouseDownMask) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor!.start()
    }
    
    func getLocation() {
        locationManager.startUpdatingLocation();
    }
    
    func getWeather(sender: AnyObject?) {
        if locationUsed == true {
            getWeatherViaLocation()
        }
        else {
            getWeatherViaZipCode()
        }
    }
    
    func getWeatherViaZipCode() {
        if zipCode != nil {
            self.weatherRetriever.getWeather(self.zipCode!, unit: self.unit!) {
                (currentTempString: String, iconString: String) in
                    self.updateWeather(currentTempString)
                    self.updateIcon(iconString)
                    self.updateUI()
            }
        }
    }
    
    func getWeatherViaLocation() {
        if self.firstTimeLocationUse == true {
            getLocation()
        }
        else if currentLocation != nil {
            self.weatherRetriever.getWeather(self.currentLocation!, unit: self.unit!) {
                (currentTempString: String, iconString: String) in
                self.updateWeather(currentTempString)
                self.updateIcon(iconString)
                self.updateUI()
            }
        }
    }
    
    func createLocationTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(locationTimerInterval, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
    }
    
    func updateIcon(iconString: String){
        self.currentImageData = NSImage(named: iconString)
    }
    
    func updateWeather(currentTempString: String){
        self.currentTempString = currentTempString
    }
    
    func updateUI(){
        if currentImageData != nil {
            self.statusItem.image = currentImageData!
        }
        if currentTempString != nil {
            self.statusItem.title = self.currentTempString!
        }
    }
    
    /* Popover stuff for listening for clicks outside the configure window */
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
        }
        eventMonitor!.start()
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor!.stop()
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func terminate(){
        NSApp.terminate(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {

        // Insert code here to tear down your application
        
//        DefaultsChecker.setDefaultZipCode(zipCode!)
//        DefaultsChecker.setDefaultRefreshInterval(String(refreshInterval!))
//        DefaultsChecker.setDefaultUnit(unit!)
//        DefaultsChecker.setDefaultLocationUsedToggle(self.locationUsed!)
    }
    
    // If user declines location permission
    func locationManager(manager: CLLocationManager,
        didFailWithError error: NSError) {
        self.getWeatherViaZipCode()
        self.locationUsed = false
        self.locationTimer?.invalidate()
            
        // Remember location toggle
        DefaultsChecker.setDefaultLocationUsedToggle(false)
    }
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        self.currentLocation = manager.location!.coordinate
        
        if self.firstTimeLocationUse == true {
            self.firstTimeLocationUse = false
            self.getWeatherViaLocation()
        }
        
        // Remember location toggle
        DefaultsChecker.setDefaultLocationUsedToggle(true)
    }
}

