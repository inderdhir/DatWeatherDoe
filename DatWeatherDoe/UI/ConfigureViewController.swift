//
//  ConfigureViewController.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var unitTextField: NSTextField!
    @IBOutlet weak var weatherSourceLabelTextField: NSTextField!
    @IBOutlet weak var refreshIntervalTextField: NSTextField!
    @IBOutlet weak var showHumidityTextField: NSTextField!
    @IBOutlet weak var roundOffDataTextField: NSTextField!
    @IBOutlet weak var weatherConditionTextField: NSTextField!

    @IBOutlet weak var fahrenheitRadioButton: NSButton!
    @IBOutlet weak var celsiusRadioButton: NSButton!
    @IBOutlet weak var allTempUnitsRadioButton: NSButton!
    @IBOutlet weak var useLocationToggleCheckBox: NSButton!
    @IBOutlet weak var weatherSourceButton: NSPopUpButton!
    @IBOutlet weak var weatherSourceTextHint: NSTextField!
    @IBOutlet weak var weatherSourceTextField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!
    @IBOutlet weak var showHumidityToggleCheckBox: NSButton!
    @IBOutlet weak var roundOffData: NSButton!
    @IBOutlet weak var weatherConditionAsTextCheckBox: NSButton!
    @IBOutlet weak var doneButton: NSButton!

    private let zipCodeHint = NSLocalizedString("[zipcode],[iso 3166 country code]", comment: "Placeholder hint for entering zip code")
    private let latLongHint = NSLocalizedString("[latitude],[longitude]", comment: "Placeholder hint for entering Lat/Long")
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

        unitTextField.stringValue = NSLocalizedString("Unit", comment: "Temperature unit")
        weatherSourceLabelTextField.stringValue = NSLocalizedString("Weather Source", comment: "Source for fetching weather")
        refreshIntervalTextField.stringValue = NSLocalizedString("Refresh Interval", comment: "Weather refresh interval")
        showHumidityTextField.stringValue = NSLocalizedString("Show Humidity", comment: "Show humidity")
        roundOffDataTextField.stringValue = NSLocalizedString("Round-off Data", comment: "Round-off Data (temperature)")
        weatherConditionTextField.stringValue = NSLocalizedString("Weather Condition (as text)", comment: "Weather condition as text")

        fahrenheitRadioButton.title = "\u{00B0}F"
        fahrenheitRadioButton.state = configManager.temperatureUnit == TemperatureUnit.fahrenheit.rawValue ? .on : .off

        celsiusRadioButton.title = "\u{00B0}C"
        celsiusRadioButton.state = configManager.temperatureUnit == TemperatureUnit.celsius.rawValue ? .on : .off

        allTempUnitsRadioButton.title = NSLocalizedString("All", comment: "Show all temperature units")
        allTempUnitsRadioButton.state = configManager.temperatureUnit == TemperatureUnit.all.rawValue ? .on : .off

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
        weatherConditionAsTextCheckBox.state = configManager.isWeatherConditionAsTextEnabled ? .on : .off

        doneButton.title = NSLocalizedString("Done", comment: "Finish configuring app")
    }

    @IBAction func radioButtonClicked(_ sender: NSButton) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fahrenheitRadioButton.state = sender == strongSelf.fahrenheitRadioButton ? .on : .off
            strongSelf.celsiusRadioButton.state = sender == strongSelf.celsiusRadioButton ? .on : .off
            strongSelf.allTempUnitsRadioButton.state = sender == strongSelf.allTempUnitsRadioButton ? .on : .off
        }
    }

    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            switch (
                strongSelf.fahrenheitRadioButton.state,
                strongSelf.celsiusRadioButton.state,
                strongSelf.allTempUnitsRadioButton.state
            ) {
            case (.off, .on, .off):
                strongSelf.configManager.temperatureUnit = TemperatureUnit.celsius.rawValue
            case (.off, .off, .on):
                strongSelf.configManager.temperatureUnit = TemperatureUnit.all.rawValue
            default:
                strongSelf.configManager.temperatureUnit = TemperatureUnit.fahrenheit.rawValue
            }

            let selectedWeatherSource = WeatherSource.allCases[strongSelf.weatherSourceButton.indexOfSelectedItem]
            strongSelf.configManager.weatherSource = selectedWeatherSource.rawValue
            strongSelf.configManager.weatherSourceText = selectedWeatherSource == .location ? nil : strongSelf.weatherSourceTextField.stringValue
            strongSelf.configManager.refreshInterval = RefreshInterval.allCases[strongSelf.refreshIntervals.indexOfSelectedItem].rawValue
            strongSelf.configManager.isShowingHumidity = strongSelf.showHumidityToggleCheckBox.state == .on
            strongSelf.configManager.isRoundingOffData = strongSelf.roundOffData.state == .on
            strongSelf.configManager.isWeatherConditionAsTextEnabled = strongSelf.weatherConditionAsTextCheckBox.state == .on

            guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
            delegate.togglePopover(sender)
        }
    }

    @IBAction func didUpdateWeatherSource(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.weatherSourceTextField.placeholderString = nil
            strongSelf.weatherSourceTextField.stringValue = ""

            let selectedWeatherSource = WeatherSource.allCases[strongSelf.weatherSourceButton.indexOfSelectedItem]
            strongSelf.weatherSourceTextField.isEnabled = selectedWeatherSource != .location

            guard selectedWeatherSource != .location else {
                strongSelf.weatherSourceTextHint.stringValue = ""
                return
            }
            switch selectedWeatherSource {
            case .latLong:
                strongSelf.weatherSourceTextHint.stringValue = strongSelf.latLongHint
                strongSelf.weatherSourceTextField.placeholderString = "42,42"
            case .zipCode:
                strongSelf.weatherSourceTextHint.stringValue = strongSelf.zipCodeHint
                strongSelf.weatherSourceTextField.placeholderString = "10021,us"
            default:
                break
            }
        }
    }
}
