//
//  NonInteractiveMenuOptionView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/21/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import SwiftUI

struct NonInteractiveMenuOptionView: View {
    let icon: DropdownIcon
    let text: String?

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon.symbolName)
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .accessibilityLabel(icon.accessibilityLabel)

            if let text {
                Text(text)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    NonInteractiveMenuOptionView(
        icon: .wind,
        text: "Test location"
    )
    .frame(width: 300, height: 100, alignment: .leading)
    .padding()
}
