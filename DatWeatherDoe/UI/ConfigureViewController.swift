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

    private let fahrenheitDegreesString = "\u{00B0}F"
    private let celsiusDegreesString = "\u{00B0}C"
    private let emptyString = ""
    private let weatherLatLongPlaceholder = "42,42"
    private let weatherZipCodePlaceholder = "10021,us"

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
        
        setupLabels()
        setupTemperatureUnits()
        setupRefreshIntervals()
        setupWeatherSources()
        setupCheckboxes()
        setupDoneButton()
    }
    
    private func setupLabels() {
        unitTextField.stringValue = NSLocalizedString("Unit", comment: "Temperature unit")
        weatherSourceLabelTextField.stringValue = NSLocalizedString(
            "Weather Source",
            comment: "Source for fetching weather"
        )
        refreshIntervalTextField.stringValue = NSLocalizedString(
            "Refresh Interval",
            comment: "Weather refresh interval"
        )
        showHumidityTextField.stringValue = NSLocalizedString(
            "Show Humidity",
            comment: "Show humidity"
        )
        roundOffDataTextField.stringValue = NSLocalizedString(
            "Round-off Data",
            comment: "Round-off Data (temperature)"
        )
        weatherConditionTextField.stringValue = NSLocalizedString(
            "Weather Condition (as text)",
            comment: "Weather condition as text"
        )
    }

    private func setupTemperatureUnits() {
        let isFahrenheitUnitSelected = configManager.temperatureUnit == TemperatureUnit.fahrenheit.rawValue
        fahrenheitRadioButton.title = fahrenheitDegreesString
        fahrenheitRadioButton.state = isFahrenheitUnitSelected ? .on : .off

        let isCelsiusUnitSelected = configManager.temperatureUnit == TemperatureUnit.celsius.rawValue
        celsiusRadioButton.title = celsiusDegreesString
        celsiusRadioButton.state = isCelsiusUnitSelected ? .on : .off

        let areAllUnitsSelected = configManager.temperatureUnit == TemperatureUnit.all.rawValue
        allTempUnitsRadioButton.title = NSLocalizedString("All", comment: "Show all temperature units")
        allTempUnitsRadioButton.state = areAllUnitsSelected ? .on : .off
    }
    
    private func setupRefreshIntervals() {
        refreshIntervals.removeAllItems()
        refreshIntervals.addItems(withTitles: RefreshInterval.allCases.map(\.title))
        
        switch configManager.refreshInterval {
        case 300: refreshIntervals.selectItem(at: 1)
        case 900: refreshIntervals.selectItem(at: 2)
        case 1800: refreshIntervals.selectItem(at: 3)
        case 3600: refreshIntervals.selectItem(at: 4)
        default: refreshIntervals.selectItem(at: 0)
        }
    }
    
    private func setupWeatherSources() {
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
    }
    
    private func setupCheckboxes() {
        showHumidityToggleCheckBox.state = configManager.isShowingHumidity ? .on : .off
        roundOffData.state = configManager.isRoundingOffData ? .on : .off
        weatherConditionAsTextCheckBox.state = configManager.isWeatherConditionAsTextEnabled ? .on : .off
    }
    
    private func setupDoneButton() {
        doneButton.title = NSLocalizedString("Done", comment: "Finish configuring app")
    }
    
    @IBAction func radioButtonClicked(_ sender: NSButton) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.fahrenheitRadioButton.state = sender == self.fahrenheitRadioButton ? .on : .off
            self.celsiusRadioButton.state = sender == self.celsiusRadioButton ? .on : .off
            self.allTempUnitsRadioButton.state = sender == self.allTempUnitsRadioButton ? .on : .off
        }
    }

    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.setTemperateUnit()
            self.setWeatherSource()
            self.setConfigOptions()
            self.togglePopover(sender)
        }
    }
    
    private func setTemperateUnit() {
        switch (
            self.fahrenheitRadioButton.state,
            self.celsiusRadioButton.state,
            self.allTempUnitsRadioButton.state
        ) {
        case (.off, .on, .off):
            self.configManager.temperatureUnit = TemperatureUnit.celsius.rawValue
        case (.off, .off, .on):
            self.configManager.temperatureUnit = TemperatureUnit.all.rawValue
        default:
            self.configManager.temperatureUnit = TemperatureUnit.fahrenheit.rawValue
        }
    }

    private func setWeatherSource() {
        let selectedWeatherSource = WeatherSource.allCases[self.weatherSourceButton.indexOfSelectedItem]
        self.configManager.weatherSource = selectedWeatherSource.rawValue
        self.configManager.weatherSourceText = selectedWeatherSource == .location ?
        nil : self.weatherSourceTextField.stringValue
    }
    
    private func setConfigOptions() {
        self.configManager.refreshInterval = RefreshInterval.allCases[self.refreshIntervals.indexOfSelectedItem].rawValue
        self.configManager.isShowingHumidity = self.showHumidityToggleCheckBox.state == .on
        self.configManager.isRoundingOffData = self.roundOffData.state == .on
        self.configManager.isWeatherConditionAsTextEnabled = self.weatherConditionAsTextCheckBox.state == .on
    }
    
    private func togglePopover(_ sender: AnyObject) {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.togglePopover(sender)
    }
    
    @IBAction func didUpdateWeatherSource(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUIWithSelections()
        }
    }
    
    private func updateUIWithSelections() {
        clearWeatherSourceStrings()
        updateUIWithWeatherSource()
    }
    
    private func clearWeatherSourceStrings() {
        self.weatherSourceTextField.placeholderString = nil
        self.weatherSourceTextField.stringValue = emptyString
    }
    
    private func updateUIWithWeatherSource() {
        let selectedWeatherSource = WeatherSource.allCases[self.weatherSourceButton.indexOfSelectedItem]
        self.weatherSourceTextField.isEnabled = selectedWeatherSource != .location
        
        guard selectedWeatherSource != .location else {
            self.weatherSourceTextHint.stringValue = emptyString
            return
        }
        switch selectedWeatherSource {
        case .latLong:
            self.weatherSourceTextHint.stringValue = self.latLongHint
            self.weatherSourceTextField.placeholderString = weatherLatLongPlaceholder
        case .zipCode:
            self.weatherSourceTextHint.stringValue = self.zipCodeHint
            self.weatherSourceTextField.placeholderString = weatherZipCodePlaceholder
        default:
            break
        }
    }
}
