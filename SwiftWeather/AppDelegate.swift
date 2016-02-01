    //
//  AppDelegate.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import SnapHTTP

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let DARK_MODE = "Dark"
        
    let weatherRetriever = WeatherRetriever()

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var currentFahrenheitTempString: String?
    var currentIconString: String?
    var currentImageData: NSImage?
    let popover = NSPopover()
            
    var zipCode: String?
    var refreshInterval: NSTimeInterval?
    
    var eventMonitor: EventMonitor?
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Check if dark/light mode
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == DARK_MODE {
            weatherRetriever.setDarkMode(true)
        }
        
        // Defaults
        self.zipCode = DefaultsChecker.getDefaultZipCode()
        self.refreshInterval = DefaultsChecker.getDefaultRefreshInterval()
        
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
        
        // Timer
        let timer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval!, target: self, selector: "getWeather", userInfo: nil, repeats: true)
        timer.fire()
        timer.fire() // Fired twice due to a bug where the icon and temperature don't display properly the first time
        
        // Event monitor to listen for clicks outside the popover
        eventMonitor = EventMonitor(mask: NSEventMask.LeftMouseDownMask) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor!.start()
    }
    
    func getWeather(){
        if zipCode != nil {
//            (self.currentFahrenheitTempString!, self.currentIconString!) = weatherRetriever.getWeather(zipCode!)
        }
        
        self.weatherRetriever.getWeather(self.zipCode!)
        print(self.weatherRetriever.currentFahrenheitTempString)

//        dispatch_sync(dispatch_get_main_queue(), {
//            print(self.weatherRetriever.currentFahrenheitTempString)
//        })
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            // Background work
//            self.weatherRetriever.getWeather(self.zipCode!)
//
//            dispatch_async(dispatch_get_main_queue(), {
//                print(self.weatherRetriever.currentFahrenheitTempString)
//
//            })
//        })
    
//        if self.currentIconString != nil {
//            self.getIcon(self.currentIconString!)
//        }
    }
    
    func getIcon(iconString: String){
        self.currentImageData = NSImage(named: iconString)
        self.updateWeather()
    }
    
    func updateWeather(){
        if currentImageData != nil {
            self.statusItem.image = currentImageData!
        }
        if currentFahrenheitTempString != nil {
            self.statusItem.title = self.currentFahrenheitTempString!
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
}

