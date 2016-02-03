    //
//  AppDelegate.swift
//  SwiftWeather
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
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var currentTempString: String?
    var currentIconString: String?
    var currentImageData: NSImage?
    let popover = NSPopover()
            
    var zipCode: String?
    var refreshInterval: NSTimeInterval?
    var unit: String?
    
    var eventMonitor: EventMonitor?
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Check if dark/light mode
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == DARK_MODE {
            weatherRetriever.setDarkMode(true)
        }
        
        // Location
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = 3000
        
        let locationTimer = NSTimer.scheduledTimerWithTimeInterval(locationTimerInterval, target: self, selector: "getLocation", userInfo: nil, repeats: true)
        locationTimer.fire()
        
        // Defaults
        self.zipCode = DefaultsChecker.getDefaultZipCode()
        self.refreshInterval = DefaultsChecker.getDefaultRefreshInterval()
        self.unit = DefaultsChecker.getDefaultUnit()
        
        // Menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Configure", action: Selector("togglePopover:"), keyEquivalent: "C"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.action = Selector("togglePopover:")
        }
        popover.contentViewController = ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)
        
        // Weather Timer
        let weatherTimer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval!, target: self, selector: "getWeather", userInfo: nil, repeats: true)
        weatherTimer.fire()
        weatherTimer.fire() // Fired twice due to a bug where the icon and temperature don't display properly the first time
        
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
    
    func getWeather(){
        if zipCode != nil {
            self.weatherRetriever.getWeather(self.zipCode!, unit: self.unit!) {
                (currentTempString: String, iconString: String) in
                    self.updateWeather(currentTempString)
                    self.updateIcon(iconString)
                    self.updateUI()
            }
        }
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

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

