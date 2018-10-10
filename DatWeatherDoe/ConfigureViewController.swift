//
//  ConfigureViewController.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

class ConfigureViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var zipCodeField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!
    @IBOutlet weak var useLocationToggleCheckBox: NSButton!
    @IBOutlet weak var fahrenheitRadioButton: NSButton!
    @IBOutlet weak var celsiusRadioButton: NSButton!

    private let intervalStrings: [String] = ["1 min", "5 min", "15 min", "30 min", "60 min"]
    private let fahrenheightString: String = "\u{00B0}F"
    private let celsiusString: String = "\u{00B0}C"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshIntervals.removeAllItems()
        refreshIntervals.addItems(withTitles: intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])
        
        zipCodeField.delegate = self

        // Radio buttons
        fahrenheitRadioButton.title = fahrenheightString
        celsiusRadioButton.title = celsiusString
        
        // Defaults
        let savedUnit = Defaults[.unit]
        if savedUnit == TemperatureUnit.fahrenheit.rawValue {
            fahrenheitRadioButton.state = .on
        } else {
            celsiusRadioButton.state = .on
        }
        if Defaults[.usingLocation] {
            useLocationToggleCheckBox.state = .on
            zipCodeField.isEnabled = false
        } else {
            useLocationToggleCheckBox.state = .off
            zipCodeField.isEnabled = true
        }
        zipCodeField.placeholderString = Defaults[.zipCode]
        
        let refreshInterval = Int(Defaults[.refreshInterval])
        switch refreshInterval {
        case 300: refreshIntervals.selectItem(at: 1)
        case 900: refreshIntervals.selectItem(at: 2)
        case 1800: refreshIntervals.selectItem(at: 3)
        case 3600: refreshIntervals.selectItem(at: 4)
        default: refreshIntervals.selectItem(at: 0)
        }
    }
    
    @IBAction func radioButtonClicked(_ sender: NSButton) {
        if sender.title == fahrenheightString {
            if fahrenheitRadioButton.state == .off {
                sender.state = .on
                celsiusRadioButton.state = .off
            }
        } else {
            if celsiusRadioButton.state == .off {
                sender.state = .on
                fahrenheitRadioButton.state = .off
            }
        }
    }
    
    @IBAction func uselocationCheckboxClicked(_ sender: NSButton) {
        zipCodeField.isEnabled = sender.state != .on
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        var refreshInterval: Double!
        switch refreshIntervals.indexOfSelectedItem {
        case 1: refreshInterval = 300
        case 2: refreshInterval = 900
        case 3: refreshInterval = 1800
        case 4: refreshInterval = 3600
        default: refreshInterval = 60
        }
        
        // Save all preferences
        let zipCode = !zipCodeField.stringValue.isEmpty ?
            zipCodeField.stringValue : "10021,us"
        let unit = fahrenheitRadioButton.state == .on ?
            TemperatureUnit.fahrenheit.rawValue : TemperatureUnit.celsius.rawValue

        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.zipCode = zipCode
            appDelegate.refreshInterval = TimeInterval(refreshInterval)
            appDelegate.unit = unit
            appDelegate.getWeatherViaZipCode()

            Defaults[.zipCode] = zipCode
            Defaults[.refreshInterval] = refreshInterval!
            Defaults[.unit] = unit
            Defaults[.usingLocation] = (useLocationToggleCheckBox.state == .on)
        }

        view.window?.close()
    }
}
