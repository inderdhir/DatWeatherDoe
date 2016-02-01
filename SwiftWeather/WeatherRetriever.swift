//
//  WeatherRetriever.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import SnapHTTP

class WeatherRetriever {
    
    let API_URL = "http://api.openweathermap.org/data/2.5/weather"

    let ZIP = "zip"
    let APPID = "appid"
    let OPENWEATHERMAP_APP_ID = "OPENWEATHERMAP_APP_ID"
    
    var APP_ID: String?
    var darkModeOn: Bool?

    var currentFahrenheitTempString: String?
    var iconString: String?
    
    
    init(){
        // Get App ID
        if let filePath = NSBundle.mainBundle().pathForResource("Keys", ofType:"plist") {
            let plist = NSDictionary(contentsOfFile:filePath)
            self.APP_ID = plist![OPENWEATHERMAP_APP_ID] as? String
        }
        
        darkModeOn = false
    }
        
    func setDarkMode(value: Bool){
        darkModeOn = value
    }

    func getWeather(zipCode: String){
        http.get(API_URL).params([ZIP: zipCode, APPID: APP_ID!]) { resp in
    
            // Error
            if resp.error != nil {
                print("\(resp.error!)")
                return
            }
            
            // Temperature
            if let dict = resp.json as? NSDictionary, mainDict = dict["main"] as? NSDictionary, temp = mainDict["temp"] {
                let doubleTemp = (temp as! NSNumber).doubleValue
                let fahrenheitTemp = ((doubleTemp - 273.15) * 1.8) + 32
                
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.maximumSignificantDigits = 3
                
                self.currentFahrenheitTempString = formatter.stringFromNumber(fahrenheitTemp)! + "\u{00B0}"
            }
            
            // Icon
            var iconString: String?
            if let weatherID = (((resp.json as! NSDictionary)["weather"] as! NSArray)[0] as! NSDictionary)["id"]{
                let weatherIDInt = weatherID.intValue
                
                if weatherIDInt >= 800 && weatherIDInt <= 900{
                    switch(weatherIDInt){
                    case 800:
                        if self.darkModeOn! == true {
                            self.iconString = WeatherConditions.SUNNY_DARK.rawValue
                        }
                        else {
                            self.iconString = WeatherConditions.SUNNY.rawValue
                        }
                        break
                    case 801:
                        if self.darkModeOn! == true {
                            self.iconString = WeatherConditions.PARTLY_CLOUDY_DARK.rawValue
                        }
                        else {
                            self.iconString = WeatherConditions.PARTLY_CLOUDY.rawValue
                        }
                        break
                    default:
                        if self.darkModeOn! == true {
                            self.iconString = WeatherConditions.CLOUDY_DARK.rawValue
                        }
                        else {
                            self.iconString = WeatherConditions.CLOUDY.rawValue
                        }
                        break
                    }
                }
                else if weatherIDInt >= 700{
                    if self.darkModeOn! == true {
                        self.iconString = WeatherConditions.MIST_DARK.rawValue
                    }
                    else {
                        self.iconString = WeatherConditions.MIST.rawValue
                    }
                }
                else if weatherIDInt >= 600{
                    if self.darkModeOn! == true {
                        self.iconString = WeatherConditions.SNOW_DARK.rawValue
                    }
                    else{
                        self.iconString = WeatherConditions.SNOW.rawValue
                    }
                }
                else if weatherIDInt >= 500{
                    if weatherIDInt == 511 {
                        if self.darkModeOn! == true {
                            self.iconString = WeatherConditions.FREEZING_RAIN_DARK.rawValue
                        }
                        else {
                            self.iconString = WeatherConditions.FREEZING_RAIN.rawValue
                        }
                    }
                    else if weatherIDInt <= 504 {
                        if self.darkModeOn! == true {
                            self.iconString = WeatherConditions.HEAVY_RAIN_DARK.rawValue
                        }
                        else {
                            self.iconString = WeatherConditions.HEAVY_RAIN.rawValue
                        }
                    }
                    else if weatherIDInt >= 520 {
                        if self.darkModeOn! == true {
                            self.iconString = WeatherConditions.PARTLY_CLOUDY_RAIN_DARK.rawValue
                        }
                        else {
                            self.iconString = WeatherConditions.PARTLY_CLOUDY_RAIN.rawValue
                        }
                    }
                }
                else if weatherIDInt >= 300{
                    if self.darkModeOn! == true {
                        self.iconString = WeatherConditions.LIGHT_RAIN_DARK.rawValue
                    }
                    else {
                        self.iconString = WeatherConditions.LIGHT_RAIN.rawValue
                    }
                }
                else if weatherIDInt >= 200{
                    if self.darkModeOn! == true {
                        self.iconString = WeatherConditions.THUNDERSTORM_DARK.rawValue
                    }
                    else {
                        self.iconString = WeatherConditions.THUNDERSTORM.rawValue
                    }
                }
            }
        }
    }
}
