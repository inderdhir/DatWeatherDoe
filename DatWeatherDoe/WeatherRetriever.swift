//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import SnapHTTP
import CoreLocation

class WeatherRetriever {
    
    let CMC_STATIONS = "cmc stations"
    
    let API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let OPENWEATHERMAP_APP_ID = "OPENWEATHERMAP_APP_ID"
    
    let formatter = NSNumberFormatter()

    // Params
    let ZIP = "zip"
    let APPID = "appid"
    let LATITUDE = "lat"
    let LONGITUDE = "lon"
    
    var APP_ID: String?
    var darkModeOn: Bool?
    
    
    init(){
        // Get App ID
        if let filePath = NSBundle.mainBundle().pathForResource("Keys", ofType:"plist") {
            let plist = NSDictionary(contentsOfFile:filePath)
            self.APP_ID = plist![OPENWEATHERMAP_APP_ID] as? String
        }
        
        // Weather string formatter
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 1
        
        darkModeOn = false
    }
        
    func setDarkMode(value: Bool){
        darkModeOn = value
    }

    // Zipcode-based weather
    func getWeather(zipCode: String, unit: String, completion: (currentTempString: String, iconString: String) -> Void){
        http.get(API_URL).params([ZIP: zipCode, APPID: APP_ID!]) { resp in
            
            // Error
            if resp.error != nil {
                print("\(resp.error!)")
                return
            }
            
            self.parseResponse(resp, unit: unit, completion: completion)
        }
    }
    
    // Location-based weather
    func getWeather(location: CLLocationCoordinate2D, unit: String, completion: (currentTempString: String, iconString: String) -> Void){
        let latitude: String = "\(location.latitude)"
        let longitude: String = "\(location.longitude)"
        
        http.get(API_URL).params([LATITUDE: latitude, LONGITUDE: longitude, APPID: APP_ID!]) { resp in
            
            // Error
            if resp.error != nil {
                print("\(resp.error!)")
                return
            }

            self.parseResponse(resp, unit: unit, completion: completion)
        }
    }
    
//    func validateZipCode(zipCode: String, completion: (zipCodeValid: Bool) -> Void){
//        http.get(API_URL).params([ZIP: zipCode, APPID: APP_ID!]) { resp in
//            var valid = false
//
//            // Error
//            if resp.error != nil {
//                print("\(resp.error!)")
//                return
//            }
//            
//            if let dict = resp.json as? NSDictionary {
//                if let base = dict["base"] as? NSString {
//                    if base != self.CMC_STATIONS {
//                        valid = true
//                    }
//                }
//            }
//            
//            completion(zipCodeValid: valid)
//        }
//    }
    
    // Response
    func parseResponse(resp: HTTP.Response, unit: String, completion: (currentTempString: String, iconString: String) -> Void)
    {
        // Temperature
        var currentTempString: String? = nil
        if let dict = resp.json as? NSDictionary, mainDict = dict["main"] as? NSDictionary, temp = mainDict["temp"], weatherDict = ((dict["weather"] as! NSArray)[0] as? NSDictionary) {
            let doubleTemp = (temp as! NSNumber).doubleValue
            var temperature: Double? = nil
            
            if unit == TemperatureUnits.F_UNIT.rawValue {
                temperature = ((doubleTemp - 273.15) * 1.8) + 32
            }
            else {
                temperature = doubleTemp - 273.15
            }
            
            currentTempString = formatter.stringFromNumber(temperature!)! + "\u{00B0}"
            
            // Icon
            var iconString: String? = nil
            if let weatherID = weatherDict["id"]{
                let weatherIDInt = weatherID.intValue
                
                if weatherIDInt >= 800 && weatherIDInt <= 900{
                    switch(weatherIDInt){
                    case 800:
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.SUNNY_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.SUNNY.rawValue
                        }
                        break
                    case 801:
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.PARTLY_CLOUDY_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.PARTLY_CLOUDY.rawValue
                        }
                        break
                    default:
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.CLOUDY_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.CLOUDY.rawValue
                        }
                        break
                    }
                }
                else if weatherIDInt >= 700{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.MIST_DARK.rawValue
                    }
                    else {
                        iconString = WeatherConditions.MIST.rawValue
                    }
                }
                else if weatherIDInt >= 600{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.SNOW_DARK.rawValue
                    }
                    else{
                        iconString = WeatherConditions.SNOW.rawValue
                    }
                }
                else if weatherIDInt >= 500{
                    if weatherIDInt == 511 {
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.FREEZING_RAIN_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.FREEZING_RAIN.rawValue
                        }
                    }
                    else if weatherIDInt <= 504 {
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.HEAVY_RAIN_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.HEAVY_RAIN.rawValue
                        }
                    }
                    else if weatherIDInt >= 520 {
                        if self.darkModeOn! == true {
                            iconString = WeatherConditions.PARTLY_CLOUDY_RAIN_DARK.rawValue
                        }
                        else {
                            iconString = WeatherConditions.PARTLY_CLOUDY_RAIN.rawValue
                        }
                    }
                }
                else if weatherIDInt >= 300{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.LIGHT_RAIN_DARK.rawValue
                    }
                    else {
                        iconString = WeatherConditions.LIGHT_RAIN.rawValue
                    }
                }
                else if weatherIDInt >= 200{
                    if self.darkModeOn! == true {
                        iconString = WeatherConditions.THUNDERSTORM_DARK.rawValue
                    }
                    else {
                        iconString = WeatherConditions.THUNDERSTORM.rawValue
                    }
                }
            }
            completion(currentTempString: currentTempString!, iconString: iconString!)
        
        }
    }
}
