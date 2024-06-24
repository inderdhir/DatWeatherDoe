//
//  ConfigureWeatherOptionsView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/8/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import SwiftUI

struct ConfigureWeatherOptionsView: View {
    @ObservedObject var viewModel: ConfigureViewModel

    var body: some View {
        Group {
            HStack {
                Text(LocalizedStringKey("Weather Source"))
                Spacer()
                Picker("", selection: $viewModel.weatherSource) {
                    Text(LocalizedStringKey("Location")).tag(WeatherSource.location)
                    Text(LocalizedStringKey("Lat/Long")).tag(WeatherSource.latLong)
                }
                .frame(width: 120)
            }

            HStack {
                Text(viewModel.weatherSource.textHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                TextField(viewModel.weatherSource.placeholder, text: $viewModel.weatherSourceText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .disabled(viewModel.weatherSource == .location)
                    .frame(width: 114)
            }
        }
    }
}

struct ConfigureWeatherOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Grid {
            ConfigureWeatherOptionsView(
                viewModel: .init(configManager: ConfigManager())
            )
        }
    }
}
