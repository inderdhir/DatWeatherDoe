//
//  WeatherValidator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class WeatherValidator {
    
    enum ValidatorType {
        case zipCode, location
    }
    
//    static let validators: [ValidatorType: WeatherValidatorType] = [
//        .zipCode: ZipCodeValidator(),
//        .location: LocationValidator()
//    ]
//
    private init() {}
    
    class func getValidator(type: ValidatorType, input: String) -> WeatherValidatorType {
        switch type {
        case .zipCode:
            return ZipCodeValidator(zipCode: input)
        case .location:
            return LocationValidator(latLong: input)
        }
    }
}
