//
//  CityWeatherResultParser.swift
//  DatWeatherDoe
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

final class CityWeatherResultParser: WeatherResultParser {
    override func parse() {
        switch weatherDataResult {
        case let .success(weatherData):
            delegate?.didUpdateWeatherData(weatherData)
        case let .failure(error):
            guard let weatherError = error as? WeatherError else { return }

            let errorString = weatherError == WeatherError.cityIncorrect ?
                errorLabels.cityErrorString :
                errorLabels.networkErrorString

            delegate?.didFailToUpdateWeatherData(errorString)
        }
    }
}
