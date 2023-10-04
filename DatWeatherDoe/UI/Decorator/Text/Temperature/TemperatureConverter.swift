//
//  TemperatureConverter.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/13/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

protocol TemperatureConverterType {
    func convertKelvinToFahrenheit(_ kelvinTemperature: Double) -> Double
    func convertKelvinToCelsius(_ kelvinTemperature: Double) -> Double
}

final class TemperatureConverter: TemperatureConverterType {
    func convertKelvinToFahrenheit(_ kelvinTemperature: Double) -> Double {
        kelvinTemperature.fahrenheitTemperature
    }
    
    func convertKelvinToCelsius(_ kelvinTemperature: Double) -> Double {
        kelvinTemperature.celsiusTemperature
    }
}

private extension Double {
    var fahrenheitTemperature: Double { ((self - 273.15) * 1.8) + 32 }
    var celsiusTemperature: Double { self - 273.15 }
}
