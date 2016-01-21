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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.image = NSImage(named: "sunny")
//            button.title = "Yo"
//            button.action = Selector("printQuote:")
        }
        
        http.get("http://api.openweathermap.org/data/2.5/weather").params(["zip": "10021,us", "appid": "2de143494c0b295cca9337e1e96b00e0"]) { resp in
            if let temp = ((resp.json as! NSDictionary)["main"] as! NSDictionary)["temp"]{
                print("\(temp)")
                if let buttonTemp = self.statusItem.button {
                    let doubleTemp = (temp as! NSNumber).doubleValue
                    let fahrenheitTemp = ((doubleTemp - 273.15) * 1.8) + 32
                    
                    let formatter = NSNumberFormatter()
                    formatter.numberStyle = .DecimalStyle
                    formatter.maximumSignificantDigits = 3
                    
                    buttonTemp.title = formatter.stringFromNumber(fahrenheitTemp)! // "$123.44"
//                    buttonTemp.image = NSImage(named: "StatusBarButtonImage")
                }
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

