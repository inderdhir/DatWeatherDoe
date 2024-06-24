//
//  ConfigureUnitOptionsView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/8/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import SwiftUI

struct ConfigureUnitOptionsView: View {
    @ObservedObject var viewModel: ConfigureViewModel

    var body: some View {
        Group {
            HStack {
                Text(LocalizedStringKey("Hide unit letter"))
                Spacer()
                Toggle(isOn: $viewModel.isUnitLetterOff) {}
            }

            HStack {
                Text(LocalizedStringKey("Hide unit ° symbol"))
                Spacer()
                Toggle(isOn: $viewModel.isUnitSymbolOff) {}
            }
        }
    }
}

struct ConfigureUnitOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        Grid {
            ConfigureUnitOptionsView(
                viewModel: .init(configManager: ConfigManager())
            )
        }
    }
}
