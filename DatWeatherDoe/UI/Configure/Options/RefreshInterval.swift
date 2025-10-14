//
//  RefreshInterval.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

enum RefreshInterval: TimeInterval, CaseIterable, Identifiable {
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    case sixtyMinutes = 3600

    var id: Self { self }

    var title: String {
        switch self {
        case .fiveMinutes:
            String(localized: "5 min")
        case .fifteenMinutes:
            String(localized: "15 min")
        case .thirtyMinutes:
            String(localized: "30 min")
        case .sixtyMinutes:
            String(localized: "60 min")
        }
    }
}
