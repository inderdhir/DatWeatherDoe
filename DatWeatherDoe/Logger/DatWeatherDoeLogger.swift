//
//  DatWeatherDoeLogger.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/28/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

protocol DatWeatherDoeLoggerType: AnyObject {
    func debug(_ message: String)
    func error(_ message: String)
}

final class DatWeatherDoeLogger: DatWeatherDoeLoggerType {
    func debug(_ message: String) {
        #if DEBUG
        print("Debug | \(message)")
        #endif
    }

    func error(_ message: String) {
        #if DEBUG
        print("Error | \(message)")
        #endif
    }
}
