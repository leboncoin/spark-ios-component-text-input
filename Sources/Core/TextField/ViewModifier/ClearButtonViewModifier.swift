//
//  ClearButtonViewModifier.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 10/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI

public struct ClearButton: ViewModifier {

    // MARK: - Properties

    @Binding var text: String
    @StateObject var viewModel: TextFieldViewModel

    // MARK: - View

    public func body(content: Content) -> some View {
        HStack(spacing: 0) {
            // TextField
            content

            // Clear Button
            if self.viewModel.isClearButton {
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: Constants.clearButtonImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledFrame(
                            width: Constants.clearButtonSize,
                            height: Constants.clearButtonSize,
                            relativeTo: .title2
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
    }
}

// MARK: - Extension

internal extension View {

    func clearButton(_ text: Binding<String>, viewModel: TextFieldViewModel) -> some View {
        self.modifier(ClearButton(text: text, viewModel: viewModel)
        )
    }
}

// MARK: - Constants

private enum Constants {
    static let clearButtonSize: CGFloat = 17
    static let clearButtonImageName = "multiply.circle.fill"
    static let clearButtonLabelKey: LocalizedStringKey = "accessibility_clear_button_label"
}
