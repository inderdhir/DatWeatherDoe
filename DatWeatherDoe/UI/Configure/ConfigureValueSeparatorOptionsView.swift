//
//  ConfigureValueSeparatorOptionsView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/8/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import SwiftUI

struct ConfigureValueSeparatorOptionsView: View {
    @ObservedObject var viewModel: ConfigureViewModel
    let valueSeparatorPlaceholder = "\u{007C}"

    var body: some View {
        HStack {
            Text(LocalizedStringKey("Separate values with"))
            Spacer()
            TextField(valueSeparatorPlaceholder, text: $viewModel.valueSeparator)
                .font(.body)
                .foregroundColor(.primary)
                .frame(width: 114)
        }
    }
}

struct ConfigureValueSeparatorOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureValueSeparatorOptionsView(
            viewModel: .init(configManager: ConfigManager())
        )
    }
}
