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
        Grid(verticalSpacing: 16) {
            HStack {
                Text(LocalizedStringKey("Unit"))
                Spacer()
                Picker("", selection: $viewModel.measurementUnit) {
                    Text(LocalizedStringKey("Metric")).tag(MeasurementUnit.metric)
                    Text(LocalizedStringKey("Imperial")).tag(MeasurementUnit.imperial)
                    Text(LocalizedStringKey("All")).tag(MeasurementUnit.all)
                }
                .frame(width: 120)
            }

            ConfigureWeatherOptionsView(viewModel: viewModel)

            HStack {
                Text(LocalizedStringKey("Refresh Interval"))
                Spacer()
                Picker("", selection: $viewModel.refreshInterval) {
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

            ConfigureUnitOptionsView(viewModel: viewModel)

            ConfigureValueSeparatorOptionsView(viewModel: viewModel)

            HStack {
                Text(LocalizedStringKey("Weather Condition Text"))
                Spacer()
                Toggle(isOn: $viewModel.isWeatherConditionAsTextEnabled) {}
            }

            HStack {
                Text(LocalizedStringKey("Weather Condition Position"))
                Spacer()
                Picker("", selection: $viewModel.weatherConditionPosition) {
                    Text(LocalizedStringKey("Before Temperature"))
                        .tag(WeatherConditionPosition.beforeTemperature)
                    Text(LocalizedStringKey("After Temperature"))
                        .tag(WeatherConditionPosition.afterTemperature)
                }
                .frame(maxWidth: 120)
            }
            .disabled(!viewModel.isWeatherConditionAsTextEnabled)
        }
        .padding()
    }
}

struct ConfigureOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureOptionsView(
            viewModel: .init(configManager: ConfigManager())
        )
        .frame(width: 380)
    }
}
