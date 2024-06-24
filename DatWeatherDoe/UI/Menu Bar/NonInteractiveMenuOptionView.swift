//
//  NonInteractiveMenuOptionView.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/21/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import SwiftUI

struct NonInteractiveMenuOptionView: View {
    let image: NSImage?
    let text: String?
    
    var body: some View {
        HStack(spacing: 6) {
            if let image {
                Image(nsImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
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
        image: NSImage(systemSymbolName: "location.north.circle", accessibilityDescription: nil),
        text: "Test location"
    )
    .frame(width: 300, height: 100, alignment: .leading)
    .padding()
}
