//
//  ConfigureViewController.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var zipCodeField: NSTextField!
    @IBOutlet weak var latLongField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!
    @IBOutlet weak var useLocationToggleCheckBox: NSButton!
    @IBOutlet weak var showHumidityToggleCheckBox: NSButton!
    @IBOutlet weak var fahrenheitRadioButton: NSButton!
    @IBOutlet weak var celsiusRadioButton: NSButton!

    private let intervalStrings = ["1 min", "5 min", "15 min", "30 min", "60 min"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshIntervals.removeAllItems()
        refreshIntervals.addItems(withTitles: intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])

        zipCodeField.delegate = self
        latLongField.delegate = self

        fahrenheitRadioButton.title = "\u{00B0}F"
        celsiusRadioButton.title = "\u{00B0}C"

        fahrenheitRadioButton.state = DefaultsManager.shared.unit == .fahrenheit ? .on : .off
        celsiusRadioButton.state = DefaultsManager.shared.unit == .celsius ? .on : .off

        let usingLocation = DefaultsManager.shared.usingLocation
        let showHumidity = DefaultsManager.shared.showHumidity
        useLocationToggleCheckBox.state = usingLocation ? .on : .off
        showHumidityToggleCheckBox.state = showHumidity ? .on : .off

        zipCodeField.isEnabled = !usingLocation
        zipCodeField.placeholderString = DefaultsManager.shared.zipCode
        latLongField.isEnabled = !usingLocation
        latLongField.placeholderString = DefaultsManager.shared.latLong

        switch DefaultsManager.shared.refreshInterval {
        case 300: refreshIntervals.selectItem(at: 1)
        case 900: refreshIntervals.selectItem(at: 2)
        case 1800: refreshIntervals.selectItem(at: 3)
        case 3600: refreshIntervals.selectItem(at: 4)
        default: refreshIntervals.selectItem(at: 0)
        }
    }
    
    @IBAction func radioButtonClicked(_ sender: NSButton) {
        fahrenheitRadioButton.state = sender == fahrenheitRadioButton ? .on : .off
        celsiusRadioButton.state = sender == celsiusRadioButton ? .on : .off
    }
    
    @IBAction func uselocationCheckboxClicked(_ sender: NSButton) {
        zipCodeField.isEnabled = sender.state != .on
        latLongField.isEnabled = sender.state != .on
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        let refreshInterval: TimeInterval
        switch refreshIntervals.indexOfSelectedItem {
        case 1: refreshInterval = 300
        case 2: refreshInterval = 900
        case 3: refreshInterval = 1800
        case 4: refreshInterval = 3600
        default: refreshInterval = 60
        }

        DefaultsManager.shared.zipCode = zipCodeField.stringValue
        DefaultsManager.shared.latLong = latLongField.stringValue
        DefaultsManager.shared.refreshInterval = refreshInterval
        DefaultsManager.shared.unit = fahrenheitRadioButton.state == .on ? .fahrenheit : .celsius
        DefaultsManager.shared.usingLocation = useLocationToggleCheckBox.state == .on
        DefaultsManager.shared.showHumidity = showHumidityToggleCheckBox.state == .on
        (NSApplication.shared.delegate as? AppDelegate)?.getWeather(nil)
        // close the popover
        (NSApplication.shared.delegate as? AppDelegate)?.togglePopover(sender)
    }
}
