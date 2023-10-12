//
//  ConfigureView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/18/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import SwiftUI

struct ConfigureView: View {
    @ObservedObject var viewModel: ConfigureViewModel

    var body: some View {
        VStack {
            ConfigureOptionsView(viewModel: viewModel)

            Button(LocalizedStringKey("Done")) {
                viewModel.saveAndCloseConfig()
            }
        }
        .padding(.bottom)
        .frame(width: 380)
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView(
            viewModel: .init(
                configManager: ConfigManager(),
                popoverManager: nil
            )
        )
    }
}
