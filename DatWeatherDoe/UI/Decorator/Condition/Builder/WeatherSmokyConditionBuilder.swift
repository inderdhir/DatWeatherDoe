//
//  WeatherSmokyConditionBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol WeatherSmokyConditionBuilderType {
    func build() -> WeatherCondition
}

final class WeatherSmokyConditionBuilder: WeatherSmokyConditionBuilderType {
    
    private let response: WeatherAPIResponse
    
    init(response: WeatherAPIResponse) {
        self.response = response
    }
    
    func build() -> WeatherCondition {
        switch response.weatherId {
        case 781:
            return .smoky(condition: .tornado)
        case 771:
            return .smoky(condition: .squall)
        case 762:
            return .smoky(condition: .ash)
        case 761:
            return .smoky(condition: .dust)
        case 751:
            return .smoky(condition: .sand)
        case 741:
            return .smoky(condition: .fog)
        case 731:
            return .smoky(condition: .sandOrDustWhirls)
        case 721:
            return .smoky(condition: .haze)
        case 711:
            return .smoky(condition: .smoke)
        case 701:
            return .smoky(condition: .mist)
        default:
            return WeatherCondition.getFallback(isNight: isNight)
        }
    }
    
    private var isNight: Bool {
        Date().isNight(sunrise: response.sunset, sunset: response.sunset)
    }
}
