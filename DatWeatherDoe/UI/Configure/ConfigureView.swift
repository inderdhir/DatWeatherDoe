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
    let onSave: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack {
            ConfigureOptionsView(viewModel: viewModel)

            HStack {
                Text(version)
                    .font(.footnote)
                    .fontWeight(.thin)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomButton(
                    text: LocalizedStringKey("Done"),
                    shortcutKey: "d",
                    onClick: onSave
                )
                .frame(maxWidth: .infinity, alignment: .center)

                Text(LocalizedStringKey("Quit"))
                    .foregroundStyle(Color.red)
                    .onTapGesture(perform: onQuit)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing])
        }
        .padding(.bottom)
        .frame(width: 380)
    }
}

struct ConfigureView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureView(
            viewModel: .init(configManager: ConfigManager()),
            version: "5.0.0",
            onSave: {},
            onQuit: {}
        )
    }
}
