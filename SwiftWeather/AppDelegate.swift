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

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var currentFahrenheitTempString: String?
    var currentImageData: NSImage?
    let popover = NSPopover()
    
    var APP_ID: String?
    
    var eventMonitor: EventMonitor?
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let filePath = NSBundle.mainBundle().pathForResource("Keys", ofType:"plist") {
            let plist = NSDictionary(contentsOfFile:filePath)
            self.APP_ID = plist!["OPENWEATHERMAP_APP_ID"] as? String
        }
        
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Configure", action: Selector("togglePopover:"), keyEquivalent: "C"))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.action = Selector("togglePopover:")
        }
        popover.contentViewController = ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getWeather", userInfo: nil, repeats: true)
        timer.fire()
        
        eventMonitor = EventMonitor(mask: NSEventMask.LeftMouseDownMask) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        eventMonitor!.start()
    }
    
    func getWeather(){
        http.get("http://api.openweathermap.org/data/2.5/weather").params(["zip": "10021,us", "appid": APP_ID!]) { resp in
            if let temp = ((resp.json as! NSDictionary)["main"] as! NSDictionary)["temp"]{
                let doubleTemp = (temp as! NSNumber).doubleValue
                let fahrenheitTemp = ((doubleTemp - 273.15) * 1.8) + 32
                    
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.maximumSignificantDigits = 3
                    
                self.currentFahrenheitTempString = formatter.stringFromNumber(fahrenheitTemp)! + "\u{00B0}"
            }
            
            var iconString: String?
            if let weatherID = (((resp.json as! NSDictionary)["weather"] as! NSArray)[0] as! NSDictionary)["id"]{
                let weatherIDInt = weatherID.intValue
                
                if weatherIDInt >= 800 && weatherIDInt <= 900{
                    switch(weatherIDInt){
                    case 800:
                        iconString = "01d"
                        break
                    case 801:
                        iconString = "02d"
                        break
                    case 802:
                        iconString = "03d"
                        break
                    default:
                        iconString = "04d"
                        break
                    }
                }
                else if weatherIDInt >= 700{
                    iconString = "50d"
                }
                else if weatherIDInt >= 600{
                    iconString = "13d"
                }
                else if weatherIDInt >= 500{
                    if weatherIDInt == 511 {
                        iconString = "13d"
                    }
                    else if weatherIDInt <= 504 {
                        iconString = "10d"
                    }
                    else if weatherIDInt >= 520 {
                        iconString = "09d"
                    }
                }
                else if weatherIDInt >= 300{
                    iconString = "09d"
                }
                else if weatherIDInt >= 200{
                    iconString = "11d"
                }
            }
            if iconString != nil {
                self.getIcon(iconString!)
            }
        }
    }
    
    func getIcon(iconString: String){
        http.get("http://openweathermap.org/img/w/" + iconString + ".png") { resp in
            self.currentImageData = NSImage(data: resp.data)
            self.updateWeather()
        }
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

