//
//  SystemLocationWeatherResultParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/17/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class SystemLocationWeatherResultParser: WeatherResultParser {
    
    override func parse() {
        switch weatherDataResult {
        case let .success(weatherData):
            delegate?.didUpdateWeatherData(weatherData)
        case .failure:
            delegate?.didFailToUpdateWeatherData(errorLabels.networkErrorString)
        }
    }
}
