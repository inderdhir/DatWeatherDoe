//
//  String+Localization.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

extension String {
    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
}
