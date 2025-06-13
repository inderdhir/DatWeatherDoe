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
                Text("Unit")
                Spacer()
                Picker("", selection: $viewModel.measurementUnit) {
                    Text("Metric").tag(MeasurementUnit.metric)
                    Text("Imperial").tag(MeasurementUnit.imperial)
                    Text("All").tag(MeasurementUnit.all)
                }
                .frame(width: 120)
            }

            ConfigureWeatherOptionsView(viewModel: viewModel)

            HStack {
                Text("Refresh Interval")
                Spacer()
                Picker("", selection: $viewModel.refreshInterval) {
                    Text("5 min").tag(RefreshInterval.fiveMinutes)
                    Text("15 min").tag(RefreshInterval.fifteenMinutes)
                    Text("30 min").tag(RefreshInterval.thirtyMinutes)
                    Text("60 min").tag(RefreshInterval.sixtyMinutes)
                }
                .frame(width: 120)
            }

            HStack {
                Text("Show Weather Icon")
                Spacer()
                Toggle(isOn: $viewModel.isShowingWeatherIcon) {}
            }

            HStack {
                Text("Show Humidity")
                Spacer()
                Toggle(isOn: $viewModel.isShowingHumidity) {}
            }

            HStack {
                Text("Show UV Index")
                Spacer()
                Toggle(isOn: $viewModel.isShowingUVIndex) {}
            }

            HStack {
                Text("Round-off Data")
                Spacer()
                Toggle(isOn: $viewModel.isRoundingOffData) {}
            }

            ConfigureUnitOptionsView(viewModel: viewModel)

            ConfigureValueSeparatorOptionsView(viewModel: viewModel)

            HStack {
                Text("Weather Condition Text")
                Spacer()
                Toggle(isOn: $viewModel.isWeatherConditionAsTextEnabled) {}
            }

            HStack {
                Text("Weather Condition Position")
                Spacer()
                Picker("", selection: $viewModel.weatherConditionPosition) {
                    Text("Before Temperature")
                        .tag(WeatherConditionPosition.beforeTemperature)
                    Text("After Temperature")
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
