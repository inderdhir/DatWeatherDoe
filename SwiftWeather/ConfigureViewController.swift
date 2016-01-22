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
        // Do view setup here.
        
        zipCodeField.placeholderString = "10021"
        refreshIntervals.removeAllItems()
        refreshIntervals.addItemsWithTitles(intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
    }
}
