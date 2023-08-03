//
//  ConfigureOptionsView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/3/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import SwiftUI

struct ConfigureOptionsView: View {
    @ObservedObject var viewModel: ConfigureViewModel
    
    var body: some View {
        Grid {
            HStack {
                Text(LocalizedStringKey("Unit"))
                Spacer()
                Picker("", selection: $viewModel.measurementUnit) {
                    Text(LocalizedStringKey("Metric")).tag(MeasurementUnit.metric)
                    Text(LocalizedStringKey("Imperial")).tag(MeasurementUnit.imperial)
                }
                .frame(width: 120)
            }
            
            HStack {
                Text(LocalizedStringKey("Weather Source"))
                Spacer()
                Picker("", selection: $viewModel.weatherSource) {
                    Text(LocalizedStringKey("Location")).tag(WeatherSource.location)
                    Text(LocalizedStringKey("Lat/Long")).tag(WeatherSource.latLong)
                    Text(LocalizedStringKey("City")).tag(WeatherSource.city)
                }
                .frame(width: 120)
            }
            HStack {
                Text(viewModel.weatherSourceTextHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                TextField(viewModel.weatherSourcePlaceholder, text: $viewModel.weatherSourceText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .disabled(viewModel.weatherSourceTextFieldDisabled)
                    .frame(width: 114)
            }
            
            HStack {
                Text(LocalizedStringKey("Refresh Interval"))
                Spacer()
                Picker("", selection: $viewModel.refreshInterval) {
                    Text(LocalizedStringKey("1 min")).tag(RefreshInterval.oneMinute)
                    Text(LocalizedStringKey("5 min")).tag(RefreshInterval.fiveMinutes)
                    Text(LocalizedStringKey("15 min")).tag(RefreshInterval.fifteenMinutes)
                    Text(LocalizedStringKey("30 min")).tag(RefreshInterval.thirtyMinutes)
                    Text(LocalizedStringKey("60 min")).tag(RefreshInterval.sixtyMinutes)
                }
                .frame(width: 120)
            }
            
            HStack {
                Text(LocalizedStringKey("Show Weather Icon"))
                Spacer()
                Toggle(isOn: $viewModel.isShowingWeatherIcon) {}
            }
            
            HStack {
                Text(LocalizedStringKey("Show Humidity"))
                Spacer()
                Toggle(isOn: $viewModel.isShowingHumidity) {}
            }
            
            HStack {
                Text(LocalizedStringKey("Round-off Data"))
                Spacer()
                Toggle(isOn: $viewModel.isRoundingOffData) {}
            }
            
            HStack {
                Text(LocalizedStringKey("Hide unit letter"))
                Spacer()
                Toggle(isOn: $viewModel.isUnitLetterOff) {}
            }

            HStack {
                Text(LocalizedStringKey("Hide unit ° symbol"))
                Spacer()
                Toggle(isOn: $viewModel.isUnitSymbolOff) {}
            }

            HStack {
                Text(LocalizedStringKey("Separate values with"))
                Spacer()
                TextField(viewModel.valueSeparatorPlaceholder, text: $viewModel.valueSeparator)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(width: 114)
            }

            HStack {
                Text(LocalizedStringKey("Weather Condition (as text)"))
                Spacer()
                Toggle(isOn: $viewModel.isWeatherConditionAsTextEnabled) {}
            }
            
            HStack {
                Text(LocalizedStringKey("Launch at Login"))
                Spacer()
                Toggle(isOn: $viewModel.launchAtLogin.isEnabled) {}
            }
        }
        .padding()
    }
}

struct ConfigureOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureOptionsView(
            viewModel: .init(
                configManager: ConfigManager(),
                popoverManager: nil
            )
        )
        .frame(width: 380)
    }
}
