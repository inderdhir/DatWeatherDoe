//
//  WeatherConditionBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol WeatherConditionBuilderType {
    func build() -> WeatherCondition
}

final class WeatherConditionBuilder: WeatherConditionBuilderType {
    
    private let response: WeatherAPIResponse
    
    init(response: WeatherAPIResponse) {
        self.response = response
    }
    
    func build() -> WeatherCondition {
        switch response.weatherId {
        case 803...804:
            return .cloudy
        case 801...802:
            return isNight ? .partlyCloudyNight : .partlyCloudy
        case 800:
            return isNight ? .clearNight : .sunny
            
        case 701...781:
            return buildSmokyWeatherCondition()
            
        case 600...622:
            return .snow
            
        case 521...531, 502...504:
            return .heavyRain
        case 511:
            return .freezingRain
        case 500...501, 520, 300...321:
            return isNight ? .lightRain : .partlyCloudyRain
            
        case 200...232:
            return .thunderstorm
            
        default:
            return WeatherCondition.getFallback(isNight: isNight)
        }
    }
    
    private var isNight: Bool {
        Date().isNight(sunrise: response.sunrise, sunset: response.sunset)
    }
    
    private func buildSmokyWeatherCondition() -> WeatherCondition {
        WeatherSmokyConditionBuilder(response: response).build()
    }
}
