//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import SwiftHTTP
import CoreLocation

class WeatherRetriever {
    
    let CMC_STATIONS = "cmc stations"
    
    let API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let OPENWEATHERMAP_APP_ID = "OPENWEATHERMAP_APP_ID"
    
    let formatter = NumberFormatter()
    
    // Params
    let ZIP = "zip"
    let APPID = "appid"
    let LATITUDE = "lat"
    let LONGITUDE = "lon"
    
    var APP_ID: String?
    var darkModeOn: Bool?
    
    
    init(){
        // Get App ID
        if let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist") {
            let plist = NSDictionary(contentsOfFile:filePath)
            self.APP_ID = plist![OPENWEATHERMAP_APP_ID] as? String
        }
        
        // Weather string formatter
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        darkModeOn = false
    }
    
    func setDarkMode(_ value: Bool){
        darkModeOn = value
    }
    
    // Zipcode-based weather
    func getWeather(_ zipCode: String, unit: String, completion: @escaping (_ currentTempString: String, _ iconString: String) -> Void){
        do {
            try HTTP.GET(API_URL, parameters: [ZIP: zipCode, APPID: APP_ID!]).start { response in
                if let err = response.error {
                    #if DEBUG
                        print("error: \(err.localizedDescription)")
                    #endif
                    return //also notify app of failure as needed
                }
                self.parseResponse(response, unit: unit, completion: completion)
                
                #if DEBUG
                    print("opt finished: \(response.description)")
                #endif
                
            }
        } catch let error {
            #if DEBUG
                print("got an error creating the request: \(error)")
            #endif
        }
    }
    
    
    // Location-based weather
    func getWeather(_ location: CLLocationCoordinate2D, unit: String, completion: @escaping (_ currentTempString: String, _ iconString: String) -> Void){
        let latitude: String = "\(location.latitude)"
        let longitude: String = "\(location.longitude)"
        
        do {
            try HTTP.GET(API_URL, parameters: [LATITUDE: latitude, LONGITUDE: longitude, APPID: APP_ID!]).start { response in
                if let err = response.error {
                    #if DEBUG
                        print("error: \(err.localizedDescription)")
                    #endif
                    return //also notify app of failure as needed
                }
                
                self.parseResponse(response, unit: unit, completion: completion)
                
                #if DEBUG
                    print("opt finished: \(response.description)")
                #endif
            }
        } catch let error {
            #if DEBUG
                print("got an error creating the request: \(error)")
            #endif
        }
    }
    
    // Response
    func parseResponse(_ resp: Response, unit: String, completion: (_ currentTempString: String, _ iconString: String) -> Void)
    {
        // Temperature
        var currentTempString: String? = nil
        
        do {
            let response: Any? = try JSONSerialization.jsonObject(with: resp.data, options: JSONSerialization.ReadingOptions())
            
            if let dict = response as? NSDictionary, let mainDict = dict["main"] as? NSDictionary, let temp = mainDict["temp"], let weatherDict = ((dict["weather"] as! NSArray)[0] as? NSDictionary) {
                let doubleTemp = (temp as! NSNumber).doubleValue
                var temperature: Double? = nil
                
                if unit == TemperatureUnits.F_UNIT.rawValue {
                    temperature = ((doubleTemp - 273.15) * 1.8) + 32
                }
                else {
                    temperature = doubleTemp - 273.15
                }
                
                currentTempString = formatter.string(from: NSNumber(value: temperature!))! + "\u{00B0}"
                
                // Icon
                var iconString: String? = nil
                if let weatherID = weatherDict["id"]{
                    if let weatherIDInt = weatherID as? Int {
                        
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
                }
                completion(currentTempString!, iconString!)
            }
        } catch let error {
            #if DEBUG
                print("got an error parsing the response: \(error)")
            #endif
        }
    }
}
