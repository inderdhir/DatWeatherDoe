//
//  AppDelegate.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import CoreLocation
import SnapHTTP

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var window: NSWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let manager = CLLocationManager()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "sunny")
            button.title = "Yo"
            button.action = Selector("printQuote:")
        }
        
//        updateLocation()
        http.get("http://api.openweathermap.org/data/2.5/weather").params(["zip": "10021,us", "appid": "2de143494c0b295cca9337e1e96b00e0"]) { resp in
//            print("JSON: \(resp.json)")
            
            if let temp = ((resp.json as! NSDictionary)["main"] as! NSDictionary)["temp"]{
                print("\(temp)")
                if let buttonTemp = self.statusItem.button {
                    buttonTemp.title = String(temp as! NSNumber)
                }
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
//    func updateLocation() {
//        if CLLocationManager.locationServicesEnabled() {
//            manager.startUpdatingLocation()
//            
////            print("\(manager.location!.coordinate.latitude)")
////               return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
//            printQuote()
//        }
//    }

//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
//        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//        
//    }

    func printQuote(sender: AnyObject) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    func printQuote() {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        
        print("\(quoteText) — \(quoteAuthor)")
    }
}

