//
//  LocationParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

final class LocationParser {
    
    func parseCoordinates(_ latLong: String) -> (CLLocationDegrees, CLLocationDegrees)? {
        let latLongCombo = latLong.split(separator: ",")
        guard latLongCombo.count == 2 else { return nil }
        
        guard let lat = CLLocationDegrees(String(latLongCombo[0])),
              let long = CLLocationDegrees(String(latLongCombo[1])) else {
                  return nil
              }
        
        return (lat, long)
    }
}
