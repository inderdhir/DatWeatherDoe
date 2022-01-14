//
//  DatWeatherDoeLoggerType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

protocol DatWeatherDoeLoggerType: AnyObject {
    func debug(_ message: String)
    func error(_ message: String)
}
