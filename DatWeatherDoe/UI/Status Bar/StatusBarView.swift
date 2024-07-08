//
//  StatusBarView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/23/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import SwiftUI

struct StatusBarView: View {
    let weatherResult: Result<WeatherData, Error>?

    var body: some View {
        if let weatherResult {
            switch weatherResult {
            case let .success(success):
                HStack {
                    if success.showWeatherIcon {
                        Image(systemName: success.weatherCondition.symbolName)
                            .renderingMode(.template)
                            .accessibilityLabel(success.weatherCondition.accessibilityLabel)
                    }
                    if let text = success.textualRepresentation {
                        Text(text)
                    }
                }
            case let .failure(failure):
                Text(failure.localizedDescription)
            }
        }
    }
}

#if DEBUG
    #Preview {
        StatusBarView(
            weatherResult: .success(
                .init(
                    showWeatherIcon: true,
                    textualRepresentation: "88",
                    weatherCondition: .cloudy,
                    response: response
                )
            )
        )
        .frame(width: 100, height: 50)
    }

    #Preview {
        StatusBarView(weatherResult: .failure(WeatherError.latLongIncorrect))
            .frame(width: 100, height: 50)
    }
#endif
