//
//  CustomButton.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/21/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import SwiftUI

struct CustomButton: View {
    let text: LocalizedStringKey
    let textColor: Color
    let shortcutKey: String
    let onClick: () -> Void
    
    init(text: LocalizedStringKey, textColor: Color = Color.white, shortcutKey: String, onClick: @escaping () -> Void) {
        self.text = text
        self.textColor = textColor
        self.shortcutKey = shortcutKey
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: onClick) {
            Text(text)
                .foregroundStyle(textColor)
                .frame(width: 110, height: 22)
        }
    }
}

#Preview {
    CustomButton(text: "See Full Weather", shortcutKey: "f") {}
}
