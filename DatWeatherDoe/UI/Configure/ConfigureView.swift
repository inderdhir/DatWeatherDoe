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
    let version: String

    var body: some View {
        VStack {
            ConfigureOptionsView(viewModel: viewModel)

            HStack {
                Spacer()
                    .frame(alignment: .leading)

                Button(LocalizedStringKey("Done")) {
                    viewModel.saveAndCloseConfig()
                }

                Text("(\(version))")
                    .font(.footnote)
                    .fontWeight(.thin)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding([.leading, .trailing])
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
            ),
            version: "4.0.0"
        )
    }
}
