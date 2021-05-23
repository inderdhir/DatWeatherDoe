//
//  WeatherDecoratorType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

protocol WeatherDecoratorType: AnyObject {
    var response: WeatherAPIResponse { get }
    var textualRepresentation: String? { get }
    var weatherCondition: WeatherCondition { get }
}
