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
    @ObservedObject var configureViewModel: ConfigureViewModel
    private var menuOptionData: MenuOptionData?
    private var version: String
    private var onSeeWeather: () -> Void
    private var onRefresh: () -> Void
    private var onSave: () -> Void

    init(
        viewModel: WeatherViewModel,
        configureViewModel: ConfigureViewModel,
        onSeeWeather: @escaping () -> Void,
        onRefresh: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.configureViewModel = configureViewModel
        self.onSeeWeather = onSeeWeather
        self.onRefresh = onRefresh
        self.onSave = onSave

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
                onSave: onSave,
                onQuit: {
                    NSApp.terminate(self)
                }
            )
        }
    }
}
