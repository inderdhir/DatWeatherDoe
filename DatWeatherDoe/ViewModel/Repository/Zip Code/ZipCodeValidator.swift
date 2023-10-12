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

    func validate() throws {
        let isZipPresent = !zipCode.isEmpty
        let isZipPresentWithCountryCode = zipCode.split(separator: ",").count == 2
        let isValid = isZipPresent && isZipPresentWithCountryCode
        if !isValid {
            throw WeatherError.zipCodeIncorrect
        }
    }
}
