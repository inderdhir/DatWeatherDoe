//
//  ZipCodeWeatherResultParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/17/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class ZipCodeWeatherResultParser: WeatherResultParser {
    override func parse() {
        switch weatherDataResult {
        case let .success(weatherData):
            delegate?.didUpdateWeatherData(weatherData)
        case let .failure(error):
            guard let weatherError = error as? WeatherError else { return }

            let errorString = weatherError == WeatherError.zipCodeIncorrect ?
                errorLabels.zipCodeErrorString :
                errorLabels.networkErrorString

            delegate?.didFailToUpdateWeatherData(errorString)
        }
    }
}
