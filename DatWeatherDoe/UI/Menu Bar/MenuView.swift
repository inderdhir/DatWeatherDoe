//
//  MenuView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/23/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: WeatherViewModel
    private var menuOptionData: MenuOptionData?
    @State private var configureViewModel: ConfigureViewModel
    private var version: String
    private var onSeeWeather: () -> Void
    private var onRefresh: () -> Void
    private var onSave: () -> Void

    init(
        viewModel: WeatherViewModel,
        onSeeWeather: @escaping () -> Void,
        onRefresh: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onSeeWeather = onSeeWeather
        self.onRefresh = onRefresh
        self.onSave = onSave

        configureViewModel = ConfigureViewModel(configManager: ConfigManager())
        version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }

    var body: some View {
        VStack {
            MenuOptionsView(
                data: viewModel.menuOptionData,
                onSeeWeather: onSeeWeather,
                onRefresh: onRefresh
            )

            Divider()

            ConfigureView(
                viewModel: configureViewModel,
                version: version,
                onSave: {
                    configureViewModel.saveConfig()
                    onSave()
                },
                onQuit: {
                    NSApp.terminate(self)
                }
            )
        }
    }
}
