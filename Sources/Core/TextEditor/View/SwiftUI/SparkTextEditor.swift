//
//  SparkTextEditor.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 20/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

// TODO: comment
// TODO: add example
// TODO: add screenshot
public struct SparkTextEditor: View {

    // MARK: - Properties

    private let theme: Theme
    private let title: String

    @Binding private var text: String

    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.textFieldIntent) private var intent // TODO: texEditor
    @Environment(\.textFieldReadOnly) private var isReadOnly // TODO: texEditor

    @FocusState private var isFocused: Bool

    private var minHeight: CGFloat = 38

    @StateObject private var viewModel = TextEditorViewModel()

    // MARK: - Initialization

    /// SparkTextEditor initializer.
    /// - Parameters:
    ///   - title: The texteditor's current placeholder.
    ///   - text: The texteditor's text binding.
    ///   - theme: The texteditor's current theme.
    // TODO: add example
    public init(
        _ title: String,
        text: Binding<String>,
        theme: Theme
    ) {
        self.title = title
        self._text = text
        self.theme = theme
    }

    // MARK: - View

    public var body: some View {
        ZStack {
            TextEditor(text: .constant(self.title))
                .foregroundStyle(self.viewModel.colors.placeholder)
                .opacity(self.text.isEmpty ? 1.0 : 0.0)
                .disabled(true)
                .scaledFrame(minHeight: self.minHeight) // TODO: Needed ?!

            TextEditor(text: self.$text)
                .foregroundStyle(self.viewModel.colors.text)
                .tint(self.viewModel.colors.text)
                .scrollIndicators(.visible)
                .focused(self.$isFocused)
        }
        .font(self.viewModel.font)
        .scaledFrame(minHeight: self.minHeight)
        .padding(.zero) // TODO: Needed ?!
        .scrollContentBackground(.hidden)
        .scaledPadding(.horizontal, self.viewModel.horizontalPadding)
        .background(self.viewModel.colors.background) // TODO: Not in the previous components
        .scaledBorder(
            width: self.viewModel.borderLayout.width,
            radius: self.viewModel.borderLayout.radius,
            colorToken: self.viewModel.colors.border
        )
        .opacity(self.viewModel.dim)
        .allowsHitTesting(!self.isReadOnly)
        .accessibilityElement()
        .accessibilityIdentifier(TextEditorAccessibilityIdentifier.view)
        .accessibilityLabel(self.title)
        .accessibilityValue(self.text)
        .onAppear() {
            self.viewModel.updateAll(
                theme: self.theme,
                intent: self.intent,
                isReadOnly: self.isReadOnly,
                isFocused: self.isFocused,
                isEnabled: self.isEnabled
            )
        }
        .onChange(of: self.intent) { intent in
            self.viewModel.intent = intent
        }
        .onChange(of: self.isReadOnly) { isReadOnly in
            self.viewModel.isReadOnly = isReadOnly
        }
        .onChange(of: self.isFocused) { isFocused in
            self.viewModel.isFocused = isFocused
        }
        .onChange(of: self.isEnabled) { isEnabled in
            self.viewModel.isEnabled = isEnabled
        }
    }
}
