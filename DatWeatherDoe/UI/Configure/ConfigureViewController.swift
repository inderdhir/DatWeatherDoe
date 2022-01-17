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
    
    private let placeholders = ConfigurationPlaceholders()
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
        fahrenheitRadioButton.title = placeholders.fahrenheitDegreesString
        fahrenheitRadioButton.state = isFahrenheitUnitSelected ? .on : .off
        
        let isCelsiusUnitSelected = configManager.temperatureUnit == TemperatureUnit.celsius.rawValue
        celsiusRadioButton.title = placeholders.celsiusDegreesString
        celsiusRadioButton.state = isCelsiusUnitSelected ? .on : .off
        
        let areAllUnitsSelected = configManager.temperatureUnit == TemperatureUnit.all.rawValue
        allTempUnitsRadioButton.title = NSLocalizedString("All", comment: "Show all temperature units")
        allTempUnitsRadioButton.state = areAllUnitsSelected ? .on : .off
    }
    
    private func setupRefreshIntervals() {
        addRefreshIntervalsToUI()
        preselectConfiguredRefreshInterval()
    }
    
    private func setupWeatherSources() {
        addWeatherSources()
        updateWeatherSourceWithSelection()
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
    
    private func addRefreshIntervalsToUI() {
        refreshIntervals.removeAllItems()
        refreshIntervals.addItems(withTitles: RefreshInterval.allCases.map(\.title))
    }
    
    private func preselectConfiguredRefreshInterval() {
        switch configManager.refreshInterval {
        case 300: refreshIntervals.selectItem(at: 1)
        case 900: refreshIntervals.selectItem(at: 2)
        case 1800: refreshIntervals.selectItem(at: 3)
        case 3600: refreshIntervals.selectItem(at: 4)
        default: refreshIntervals.selectItem(at: 0)
        }
    }
    
    private func addWeatherSources() {
        weatherSourceButton.removeAllItems()
        weatherSourceButton.addItems(withTitles: WeatherSource.allCases.map(\.title))
    }
    
    private func updateWeatherSourceWithSelection() {
        let selectedWeatherSource =
        WeatherSource(rawValue: configManager.weatherSource) ?? .location
        updateWeatherSourceTextHint(selectedWeatherSource)
        
        let selectedWeatherSourceIndex = getSelectionIndexForWeatherSource(selectedWeatherSource)
        updateWeatherSourceSelection(selectedWeatherSourceIndex)
        
        let isNotLocationSource = selectedWeatherSourceIndex != 0
        setWeatherSourceTextFieldEnabled(isNotLocationSource)
        
        if let weatherSourceText = configManager.weatherSourceText {
            updateWeatherSourceTextField(weatherSourceText)
        }
    }
    
    private func updateWeatherSourceTextHint(_ source: WeatherSource) {
        switch source {
        case .location:
            weatherSourceTextHint.stringValue = placeholders.emptyString
        case .latLong:
            weatherSourceTextHint.stringValue = placeholders.latLongHint
        case .zipCode:
            weatherSourceTextHint.stringValue = placeholders.zipCodeHint
        }
    }
    
    private func getSelectionIndexForWeatherSource(_ source: WeatherSource) -> Int {
        switch source {
        case .location:
            return 0
        case .latLong:
            return 1
        case .zipCode:
            return 2
        }
    }
    
    private func updateWeatherSourceSelection(_ index: Int) {
        weatherSourceButton.selectItem(at: index)
    }

    private func setWeatherSourceTextFieldEnabled(_ enabled: Bool) {
        weatherSourceTextField.isEnabled = enabled
    }
    
    private func updateWeatherSourceTextField(_ text: String) {
        weatherSourceTextField.stringValue = text
    }
    
    @IBAction private func radioButtonClicked(_ sender: NSButton) {
        DispatchQueue.main.async { [weak self] in
            self?.updateTemperatureRadioButtonsAfterSelection(sender)
        }
    }
    
    @IBAction private func doneButtonPressed(_ sender: AnyObject) {
        DispatchQueue.main.async { [weak self] in
            self?.setTemperateUnitForConfig()
            self?.setWeatherSourceForConfig()
            self?.setOtherOptionsForConfig()
            self?.togglePopover(sender)
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
    
    private func setWeatherSourceForConfig() {
        let selectedWeatherSource = WeatherSource.allCases[weatherSourceButton.indexOfSelectedItem]
        configManager.weatherSource = selectedWeatherSource.rawValue
        configManager.weatherSourceText = selectedWeatherSource == .location ?
        nil : weatherSourceTextField.stringValue
    }
    
    private func setOtherOptionsForConfig() {
        configManager.refreshInterval = RefreshInterval.allCases[refreshIntervals.indexOfSelectedItem].rawValue
        configManager.isShowingHumidity = showHumidityToggleCheckBox.state == .on
        configManager.isRoundingOffData = roundOffData.state == .on
        configManager.isWeatherConditionAsTextEnabled = weatherConditionAsTextCheckBox.state == .on
    }
    
    private func togglePopover(_ sender: AnyObject) {
        popoverManager?.togglePopover(sender)
    }
    
    @IBAction private func didUpdateWeatherSource(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUIWithSelections()
        }
    }
    
    private func updateUIWithSelections() {
        clearWeatherSourceStrings()
        updateUIWithWeatherSource()
    }
    
    private func clearWeatherSourceStrings() {
        weatherSourceTextField.placeholderString = nil
        weatherSourceTextField.stringValue = placeholders.emptyString
    }
    
    private func updateUIWithWeatherSource() {
        let selectedWeatherSource = WeatherSource.allCases[weatherSourceButton.indexOfSelectedItem]
        
        let weatherSourceTextFieldEnabled = selectedWeatherSource != .location
        setWeatherSourceTextFieldEnabled(weatherSourceTextFieldEnabled)
        
        updateWeatherSourceTextHint(selectedWeatherSource)
        updateWeatherSourceTextPlaceholder(selectedWeatherSource)
    }
    
    private func updateWeatherSourceTextPlaceholder(_ source: WeatherSource) {
        switch source {
        case .location:
            break
        case .latLong:
            weatherSourceTextField.placeholderString = placeholders.weatherLatLongPlaceholder
        case .zipCode:
            weatherSourceTextField.placeholderString = placeholders.weatherZipCodePlaceholder
        }
    }
}
