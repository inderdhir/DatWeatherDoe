//
//  ZipCodeValidator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/13/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class ZipCodeValidator: WeatherValidatorType {
    private let zipCode: String
    
    init(zipCode: String) {
        self.zipCode = zipCode
    }
    
    func validate() -> Bool { !zipCode.isEmpty }
}
