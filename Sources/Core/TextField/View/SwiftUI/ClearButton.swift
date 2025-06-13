//
//  ClearButton.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 10/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI

internal struct ClearButton: View {

    // MARK: - Properties

    @Binding var text: String
    @Binding var textFieldID: String

    // MARK: - View

    var body: some View {
        Button {
            self.text = ""
            self.textFieldID = UUID().uuidString
        } label: {
            Image(systemName: Constants.clearButtonImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledFrame(
                    width: Constants.clearButtonSize,
                    height: Constants.clearButtonSize,
                    relativeTo: .body
                )
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .frame(maxHeight: .infinity)
                .scaledFrame(width: TextInputConstants.height)
                .aspectRatio(1, contentMode: .fit)
        }
        .accessibilityLabel(.init(Constants.clearButtonLabelKey, bundle: .current))
        .accessibilityIdentifier(TextFieldAccessibilityIdentifier.clearButton)
        .accessibilityShowsLargeContentViewer {
            Image(systemName: Constants.clearButtonImageName)
            Text(Constants.clearButtonLabelKey, bundle: .current)
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Constants

private enum Constants {
    static let clearButtonSize: CGFloat = 17
    static let clearButtonImageName = "multiply.circle.fill"
    static let clearButtonLabelKey: LocalizedStringKey = "accessibility_clear_button_label"
}

// MARK: - Preview

#Preview {
    ClearButton(text: .constant("Hello"), textFieldID: .constant("ID"))
}
