//
//  ConfigureViewController.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

final class ConfigureViewController: NSViewController, NSTextFieldDelegate {
    
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
    
    private let configManager: ConfigManagerType
    private weak var popoverManager: PopoverManager?
    
    init(configManager: ConfigManagerType, popoverManager: PopoverManager) {
        self.configManager = configManager
        self.popoverManager = popoverManager
        
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
        fahrenheitRadioButton.title = TemperatureUnit.fahrenheit.degreesString
        fahrenheitRadioButton.state = isFahrenheitUnitSelected ? .on : .off
        
        let isCelsiusUnitSelected = configManager.temperatureUnit == TemperatureUnit.celsius.rawValue
        celsiusRadioButton.title = TemperatureUnit.celsius.degreesString
        celsiusRadioButton.state = isCelsiusUnitSelected ? .on : .off
        
        let isAllUnitsSelected = configManager.temperatureUnit == TemperatureUnit.all.rawValue
        allTempUnitsRadioButton.title = NSLocalizedString("All", comment: "Show all temperature units")
        allTempUnitsRadioButton.state = isAllUnitsSelected ? .on : .off
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
        
        let selectedWeatherSource = WeatherSource(rawValue: configManager.weatherSource)!
        updateUIWith(weatherSource: selectedWeatherSource)
    }
    
    private func setupCheckboxes() {
        showHumidityToggleCheckBox.state = configManager.isShowingHumidity ? .on : .off
        roundOffData.state = configManager.isRoundingOffData ? .on : .off
        weatherConditionAsTextCheckBox.state =
        configManager.isWeatherConditionAsTextEnabled ? .on : .off
    }
    
    private func setupDoneButton() {
        doneButton.title = NSLocalizedString("Done", comment: "Finish configuring app")
    }
    
    private func updateUIWith(weatherSource: WeatherSource) {
        weatherSourceTextHint.stringValue = weatherSource.textHint
        
        let selectedWeatherSourceIndex = weatherSource.menuIndex
        weatherSourceButton.selectItem(at: selectedWeatherSourceIndex)
        
        let isNotLocationSource = weatherSource != .location
        weatherSourceTextField.isEnabled = isNotLocationSource
        
        if let weatherSourceText = configManager.weatherSourceText {
            weatherSourceTextField.stringValue = weatherSourceText
        } else {
            weatherSourceTextField.placeholderString = weatherSource.placeholder
        }
    }
    
    @IBAction private func radioButtonClicked(_ sender: NSButton) {
        DispatchQueue.main.async { [weak self] in
            self?.updateTemperatureRadioButtonsAfterSelection(sender)
        }
    }
    
    @IBAction private func doneButtonPressed(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.setTemperateUnitForConfig()
            
            let selectedWeatherSource = WeatherSource.allCases[self.weatherSourceButton.indexOfSelectedItem]
            let selectedRefreshInterval = RefreshInterval.allCases[self.refreshIntervals.indexOfSelectedItem]
            self.setConfigWith(weatherSource: selectedWeatherSource, refreshInterval: selectedRefreshInterval)
            
            self.popoverManager?.togglePopover(sender)
        }
    }
    
    private func updateTemperatureRadioButtonsAfterSelection(_ sender: NSButton) {
        fahrenheitRadioButton.state = sender == fahrenheitRadioButton ? .on : .off
        celsiusRadioButton.state = sender == celsiusRadioButton ? .on : .off
        allTempUnitsRadioButton.state = sender == allTempUnitsRadioButton ? .on : .off
    }
    
    private func setTemperateUnitForConfig() {
        switch (
            fahrenheitRadioButton.state,
            celsiusRadioButton.state,
            allTempUnitsRadioButton.state
        ) {
        case (.off, .on, .off):
            configManager.temperatureUnit = TemperatureUnit.celsius.rawValue
        case (.off, .off, .on):
            configManager.temperatureUnit = TemperatureUnit.all.rawValue
        default:
            configManager.temperatureUnit = TemperatureUnit.fahrenheit.rawValue
        }
    }
    
    private func setConfigWith(weatherSource: WeatherSource, refreshInterval: RefreshInterval) {
        let configCommitter = ConfigurationCommitter(configManager: configManager)
        configCommitter.setWeatherSource(weatherSource, sourceText: weatherSourceTextField.stringValue)
        configCommitter.setOtherOptionsForConfig(
            refreshInterval: refreshInterval,
            isShowingHumidity: showHumidityToggleCheckBox.state == .on,
            isRoundingOffData: roundOffData.state == .on,
            isWeatherConditionAsTextEnabled: weatherConditionAsTextCheckBox.state == .on
        )
    }
    
    @IBAction private func didUpdateWeatherSource(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            let selectedWeatherSource = WeatherSource.allCases[self.weatherSourceButton.indexOfSelectedItem]
            self.updateUIWith(weatherSource: selectedWeatherSource)
        }
    }
}
