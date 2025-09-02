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
            NSLocalizedString("5 min", comment: "5 min refresh interval")
        case .fifteenMinutes:
            NSLocalizedString("15 min", comment: "15 min refresh interval")
        case .thirtyMinutes:
            NSLocalizedString("30 min", comment: "30 min refresh interval")
        case .sixtyMinutes:
            NSLocalizedString("60 min", comment: "60 min refresh interval")
        }
    }
}
