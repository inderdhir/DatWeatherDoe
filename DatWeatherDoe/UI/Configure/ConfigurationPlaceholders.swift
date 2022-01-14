//
//  ConfigurationPlaceholders.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class ConfigurationPlaceholders {
    let fahrenheitDegreesString = "\u{00B0}F"
    let celsiusDegreesString = "\u{00B0}C"
    let emptyString = ""
    let weatherLatLongPlaceholder = "42,42"
    let weatherZipCodePlaceholder = "10021,us"
    
    let zipCodeHint = NSLocalizedString("[zipcode],[iso 3166 country code]", comment: "Placeholder hint for entering zip code")
    let latLongHint = NSLocalizedString("[latitude],[longitude]", comment: "Placeholder hint for entering Lat/Lonet smartindent")
}
