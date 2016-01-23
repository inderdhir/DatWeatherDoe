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
    
    let ZIP_CODE_CONFIG = "ZipCodeConfig"
    let REFRESH_INTERVAL_CONFIG = "RefreshIntervalConfig"
    
    let DARK_MODE = "Dark"
    let LIGHT_MODE = "Light"
    
    let SUNNY = "Sunny"
    let SUNNY_DARK = "SunnyDark"
    let PARTLY_CLOUDY = "PartlyCloudy"
    let PARTLY_CLOUDY_DARK = "PartlyCloudyDark"
    let CLOUDY = "Cloudy"
    let CLOUDY_DARK = "CloudyDark"
    let MIST = "Mist"
    let MIST_DARK = "MistDark"
    let SNOW = "Snow"
    let SNOW_DARK = "SnowDark"
    let FREEZING_RAIN = "FreezingRain"
    let FREEZING_RAIN_DARK = "FreezingRainDark"
    let HEAVY_RAIN = "HeavyRain"
    let HEAVY_RAIN_DARK = "HeavyRainDark"
    let PARTLY_CLOUDY_RAIN = "PartlyCloudyRain"
    let PARTLY_CLOUDY_RAIN_DARK = "PartlyCloudyRainDark"
    let LIGHT_RAIN = "LightRain"
    let LIGHT_RAIN_DARK = "LightRainDark"
    let THUNDERSTORM = "Thunderstorm"
    let THUNDERSTORM_DARK = "ThunderstormDark"
    
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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let savedZipCode = defaults.stringForKey(ZIP_CODE_CONFIG){
            zipCode = savedZipCode
        }
        else {
            zipCode = "10021,us"
        }
        if let savedRefreshInterval = defaults.stringForKey(REFRESH_INTERVAL_CONFIG){
            refreshInterval = NSTimeInterval(savedRefreshInterval)
        }
        else {
            refreshInterval = 60
        }
        
        print(zipCode)
        print(refreshInterval)
        
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
                            iconString = self.SUNNY_DARK
                        }
                        else {
                            iconString = self.SUNNY
                        }
                        break
                    case 801:
                        if self.darkModeOn! == true {
                            iconString = self.PARTLY_CLOUDY_DARK
                        }
                        else {
                            iconString = self.PARTLY_CLOUDY
                        }
                        break
                    default:
                        if self.darkModeOn! == true {
                            iconString = self.CLOUDY_DARK
                        }
                        else {
                            iconString = self.CLOUDY
                        }
                        break
                    }
                }
                else if weatherIDInt >= 700{
                    if self.darkModeOn! == true {
                        iconString = self.MIST_DARK
                    }
                    else {
                        iconString = self.MIST
                    }
                }
                else if weatherIDInt >= 600{
                    if self.darkModeOn! == true {
                        iconString = self.SNOW_DARK
                    }
                    else{
                        iconString = self.SNOW
                    }
                }
                else if weatherIDInt >= 500{
                    if weatherIDInt == 511 {
                        if self.darkModeOn! == true {
                            iconString = self.FREEZING_RAIN_DARK
                        }
                        else {
                            iconString = self.FREEZING_RAIN
                        }
                    }
                    else if weatherIDInt <= 504 {
                        if self.darkModeOn! == true {
                            iconString = self.HEAVY_RAIN_DARK
                        }
                        else {
                            iconString = self.HEAVY_RAIN
                        }
                    }
                    else if weatherIDInt >= 520 {
                        if self.darkModeOn! == true {
                            iconString = self.PARTLY_CLOUDY_RAIN_DARK
                        }
                        else {
                            iconString = self.PARTLY_CLOUDY_RAIN
                        }
                    }
                }
                else if weatherIDInt >= 300{
                    if self.darkModeOn! == true {
                        iconString = self.LIGHT_RAIN_DARK
                    }
                    else {
                        iconString = self.LIGHT_RAIN
                    }
                }
                else if weatherIDInt >= 200{
                    if self.darkModeOn! == true {
                        iconString = self.THUNDERSTORM_DARK
                    }
                    else {
                        iconString = self.THUNDERSTORM
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

