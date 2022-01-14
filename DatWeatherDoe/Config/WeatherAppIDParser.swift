//
//  WeatherAppIDParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class WeatherAppIDParser {
    
    func parse() -> String {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let appId = plist["OPENWEATHERMAP_APP_ID"] as? String else {
                  fatalError("Unable to find OPENWEATHERMAP_APP_ID in Keys.plist")
              }
        
        return appId
    }
}
