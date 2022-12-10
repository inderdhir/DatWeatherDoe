//
//  WeatherResultParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/17/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

class WeatherResultParser {
    let weatherDataResult: Result<WeatherData, Error>
    let errorLabels: ErrorLabels
    weak var delegate: WeatherViewModelDelegate?
    
    init(
        weatherDataResult: Result<WeatherData, Error>,
        delegate: WeatherViewModelDelegate?,
        errorLabels: ErrorLabels
    ) {
        self.weatherDataResult = weatherDataResult
        self.delegate = delegate
        self.errorLabels = errorLabels
    }
    
    func parse() {}
}
