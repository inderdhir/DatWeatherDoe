//
//  ConfigureViewController.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController {
    
    let intervalStrings: [String] = ["1 min", "5 min", "15 min", "30 min", "60 min"]
    
    @IBOutlet weak var zipCodeField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipCodeField.placeholderString = "10021"
        refreshIntervals.removeAllItems()
        refreshIntervals.addItemsWithTitles(intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        var zipCode: String? = nil
        var refreshInterval: Double? = nil
        
        switch refreshIntervals.indexOfSelectedItem {
        case 1:
            refreshInterval = 300
            break
        case 2  :
            refreshInterval = 900
            break
        case 3:
            refreshInterval = 1800
            break
        case 4:
            refreshInterval = 3600
            break
        default:
            refreshInterval = 60
            break
        }
        
        if(zipCodeField.stringValue.characters.count > 0){
            zipCode = zipCodeField.stringValue + ",us"
        }
        else{
            zipCode = "10021,us"
        }
        
        appDelegate.zipCode = zipCode!
        appDelegate.refreshInterval = NSTimeInterval(refreshInterval!)
        appDelegate.getWeather()
        
        DefaultsChecker.setDefaultZipCode(zipCode!)
        DefaultsChecker.setDefaultRefreshInterval(String(refreshInterval!))
        
        self.view.window?.close()
    }
}
