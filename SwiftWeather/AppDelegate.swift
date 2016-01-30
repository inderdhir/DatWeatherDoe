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
    let LIGHT_MODE = "Light"
    
    var darkModeOn: Bool?

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var currentFahrenheitTempString: String?
    var currentImageData: NSImage?
    let popover = NSPopover()
    
    var APP_ID: String?
    
    let API_URL = "http://api.openweathermap.org/data/2.5/weather"
    
    var zipCode: String?
    var refreshInterval: NSTimeInterval?
    
    var eventMonitor: EventMonitor?
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Check if dark/light mode
        darkModeOn = false
        let appearance = NSUserDefaults.standardUserDefaults().stringForKey("AppleInterfaceStyle") ?? "Light"
        if appearance == DARK_MODE {
            darkModeOn = true
        }
        
        if let filePath = NSBundle.mainBundle().pathForResource("Keys", ofType:"plist") {
            let plist = NSDictionary(contentsOfFile:filePath)
            self.APP_ID = plist!["OPENWEATHERMAP_APP_ID"] as? String
        }
        
        zipCode = DefaultsChecker.getDefaultZipCode()
        refreshInterval = DefaultsChecker.getDefaultRefreshInterval()
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Configure", action: Selector("togglePopover:"), keyEquivalent: "C"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.action = Selector("togglePopover:")
        }
        popover.contentViewController = ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(refreshInterval!, target: self, selector: "getWeather", userInfo: nil, repeats: true)
        timer.fire()
        timer.fire() // Fired twice due to a bug where the icon and temperature don't display properly the first time
        
        eventMonitor = EventMonitor(mask: NSEventMask.LeftMouseDownMask) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor!.start()
    }
    
    func getWeather(){
        http.get(API_URL).params(["zip": zipCode!, "appid": APP_ID!]) { resp in
            
            // Error
            if resp.error != nil {
                print("\(resp.error!)")
                return
            }
            
            // Temperature
            if let dict = resp.json as? NSDictionary, mainDict = dict["main"] as? NSDictionary, temp = mainDict["temp"] {
                let doubleTemp = (temp as! NSNumber).doubleValue
                let fahrenheitTemp = ((doubleTemp - 273.15) * 1.8) + 32
                
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.maximumSignificantDigits = 3
                
                self.currentFahrenheitTempString = formatter.stringFromNumber(fahrenheitTemp)! + "\u{00B0}"
            }
            
            // Icon
            var iconString: String?
            if let weatherID = (((resp.json as! NSDictionary)["weather"] as! NSArray)[0] as! NSDictionary)["id"]{
                let weatherIDInt = weatherID.intValue
                
                if weatherIDInt >= 800 && weatherIDInt <= 900{
                    switch(weatherIDInt){
                    case 800:
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.SUNNY_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.SUNNY.rawValue
                        }
                        break
                    case 801:
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.PARTLY_CLOUDY_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.PARTLY_CLOUDY.rawValue
                        }
                        break
                    default:
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.CLOUDY_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.CLOUDY.rawValue
                        }
                        break
                    }
                }
                else if weatherIDInt >= 700{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.MIST_DARK.rawValue
                    }
                    else {
                        iconString = WeatherConditions.MIST.rawValue
                    }
                }
                else if weatherIDInt >= 600{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.SNOW_DARK.rawValue
                    }
                    else{
                        iconString = WeatherConditions.SNOW.rawValue
                    }
                }
                else if weatherIDInt >= 500{
                    if weatherIDInt == 511 {
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.FREEZING_RAIN_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.FREEZING_RAIN.rawValue
                        }
                    }
                    else if weatherIDInt <= 504 {
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.HEAVY_RAIN_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.HEAVY_RAIN.rawValue
                        }
                    }
                    else if weatherIDInt >= 520 {
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.PARTLY_CLOUDY_RAIN_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.PARTLY_CLOUDY_RAIN.rawValue
                        }
                    }
                }
                else if weatherIDInt >= 300{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.LIGHT_RAIN_DARK.rawValue
                    }
                    else {
                        iconString = WeatherConditions.LIGHT_RAIN.rawValue
                    }
                }
                else if weatherIDInt >= 200{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.THUNDERSTORM_DARK.rawValue
                    }
                    else {
                        iconString = WeatherConditions.THUNDERSTORM.rawValue
                    }
                }
            }
            if iconString != nil {
                self.getIcon(iconString!)
            }
        }
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

