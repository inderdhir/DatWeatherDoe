//
//  WeatherDecoratorType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

protocol WeatherDecoratorType: AnyObject {
    var response: WeatherAPIResponse { get }
    func textualRepresentation(sunsetTime: TimeInterval) -> String
    func weatherCondition(sunsetTime: TimeInterval) -> WeatherCondition
}
