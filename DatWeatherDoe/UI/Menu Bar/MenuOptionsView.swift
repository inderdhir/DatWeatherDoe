//
//  MenuOptionsView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/21/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import SwiftUI

struct MenuOptionData {
    let locationText: String
    let weatherText: String
    let sunriseSunsetText: String
    let tempHumidityWindText: String
}

struct MenuOptionsView: View {
    let data: MenuOptionData?
    let onSeeWeather: () -> Void
    let onRefresh: () -> Void

    private let iconMapper = DropdownIconMapper()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading) {
                NonInteractiveMenuOptionView(icon: .location, text: data?.locationText)
                NonInteractiveMenuOptionView(icon: .thermometer, text: data?.weatherText)
                NonInteractiveMenuOptionView(icon: .sun, text: data?.sunriseSunsetText)
                NonInteractiveMenuOptionView(icon: .wind, text: data?.tempHumidityWindText)
            }

            HStack {
                CustomButton(
                    text: LocalizedStringKey("See Full Weather"),
                    shortcutKey: "f",
                    onClick: onSeeWeather
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                    .frame(maxWidth: .infinity)

                CustomButton(text: LocalizedStringKey("Refresh"), shortcutKey: "r", onClick: onRefresh)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
