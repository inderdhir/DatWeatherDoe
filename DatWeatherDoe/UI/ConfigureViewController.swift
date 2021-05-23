//
//  ConfigureViewController.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var fahrenheitRadioButton: NSButton!
    @IBOutlet weak var celsiusRadioButton: NSButton!
    @IBOutlet weak var useLocationToggleCheckBox: NSButton!
    @IBOutlet weak var weatherSourceButton: NSPopUpButton!
    @IBOutlet weak var weatherSourceTextHint: NSTextField!
    @IBOutlet weak var weatherSourceTextField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!
    @IBOutlet weak var showHumidityToggleCheckBox: NSButton!
    @IBOutlet weak var roundOffData: NSButton!
    private let zipCodeHint = "[zipcode],[iso 3166 country code]"
    private let latLongHint = "[latitude],[longitude]"
    private let configManager: ConfigManagerType

    init(configManager: ConfigManagerType) {
        self.configManager = configManager
        super.init(nibName: "ConfigureViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fahrenheitRadioButton.title = "\u{00B0}F"
        fahrenheitRadioButton.state = configManager.temperatureUnit == TemperatureUnit.fahrenheit.rawValue ? .on : .off

        celsiusRadioButton.title = "\u{00B0}C"
        celsiusRadioButton.state = configManager.temperatureUnit == TemperatureUnit.celsius.rawValue ? .on : .off

        refreshIntervals.removeAllItems()
        refreshIntervals.addItems(withTitles: RefreshInterval.allCases.map(\.title))
        switch configManager.refreshInterval {
        case 300: refreshIntervals.selectItem(at: 1)
        case 900: refreshIntervals.selectItem(at: 2)
        case 1800: refreshIntervals.selectItem(at: 3)
        case 3600: refreshIntervals.selectItem(at: 4)
        default: refreshIntervals.selectItem(at: 0)
        }

        weatherSourceButton.removeAllItems()
        weatherSourceButton.addItems(withTitles: WeatherSource.allCases.map(\.title))
        let selectedIndex: Int
        switch WeatherSource(rawValue: configManager.weatherSource) {
        case .latLong:
            weatherSourceTextHint.stringValue = latLongHint
            selectedIndex = 1
        case .zipCode:
            weatherSourceTextHint.stringValue = zipCodeHint
            selectedIndex = 2
        default:
            selectedIndex = 0
        }
        weatherSourceButton.selectItem(at: selectedIndex)

        weatherSourceTextField.isEnabled = selectedIndex != 0
        if let weatherSourceText = configManager.weatherSourceText {
            weatherSourceTextField.stringValue = weatherSourceText
        }

        showHumidityToggleCheckBox.state = configManager.isShowingHumidity ? .on : .off

        roundOffData.state = configManager.isRoundingOffData ? .on : .off
    }

    @IBAction func radioButtonClicked(_ sender: NSButton) {
        fahrenheitRadioButton.state = sender == fahrenheitRadioButton ? .on : .off
        celsiusRadioButton.state = sender == celsiusRadioButton ? .on : .off
    }

    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            let selectedWeatherSource = WeatherSource.allCases[self.weatherSourceButton.indexOfSelectedItem]
            self.configManager.weatherSource = selectedWeatherSource.rawValue
            self.configManager.weatherSourceText = selectedWeatherSource == .location ? nil : self.weatherSourceTextField.stringValue
            self.configManager.refreshInterval = RefreshInterval.allCases[self.refreshIntervals.indexOfSelectedItem].rawValue
            self.configManager.temperatureUnit = self.fahrenheitRadioButton.state == .on ?
                TemperatureUnit.fahrenheit.rawValue : TemperatureUnit.celsius.rawValue
            self.configManager.isShowingHumidity = self.showHumidityToggleCheckBox.state == .on
            self.configManager.isRoundingOffData = self.roundOffData.state == .on

            guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
            delegate.togglePopover(sender)
        }
    }

    @IBAction func didUpdateWeatherSource(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            self.weatherSourceTextField.placeholderString = nil
            self.weatherSourceTextField.stringValue = ""

            let selectedWeatherSource = WeatherSource.allCases[self.weatherSourceButton.indexOfSelectedItem]
            self.weatherSourceTextField.isEnabled = selectedWeatherSource != .location

            guard selectedWeatherSource != .location else {
                self.weatherSourceTextHint.stringValue = ""
                return
            }
            switch selectedWeatherSource {
            case .latLong:
                self.weatherSourceTextHint.stringValue = self.latLongHint
                self.weatherSourceTextField.placeholderString = "42,42"
            case .zipCode:
                self.weatherSourceTextHint.stringValue = self.zipCodeHint
                self.weatherSourceTextField.placeholderString = "10021,us"
            default:
                break
            }
        }
    }
}
