//
//  CityValidator.swift
//  DatWeatherDoe
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

final class CityValidator: WeatherValidatorType {
    private let city: String
    
    init(city: String) {
        self.city = city
    }
        
    func validate() throws {
        let isCityPresent = !city.isEmpty
        let isCityPresentWithCountryCode = city.split(separator: ",").count == 2
        let isValid = isCityPresent && isCityPresentWithCountryCode
        if !isValid {
            throw WeatherError.cityIncorrect
        }
    }
}
