//
//  SparkTextField.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 10/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

// TODO: add the addons
// TODO: INFO: avoir un viewModel pour UIKit et un autre pour SwiftUI semble être la meilleur solution.

// TODO: comment
// TODO: add example
public struct SparkTextField<LeftView: View, RightView: View>: View {

    // MARK: - Properties

    private let theme: Theme
    private let titleKey: LocalizedStringKey
    private let format: TextFieldFormat?

    @Binding private var text: String

    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.textFieldIntent) private var intent
    @Environment(\.textFieldReadOnly) private var isReadOnly
    @Environment(\.textFieldClearMode) private var clearMode
    @Environment(\.textFieldSecureMode) private var isSecureMode
    @FocusState private var isFocused: Bool

    private let leftView: () -> LeftView
    private let rightView: () -> RightView

    private var height: CGFloat = TextInputConstants.height

    @StateObject private var viewModel = TextFieldViewModel()

    // MARK: - Initialization

    /// TextFieldView initializer
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    // TODO: add example
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() }
    ) {
        self.titleKey = titleKey
        self._text = text
        self.theme = theme
        self.format = nil

        self.leftView = leftView
        self.rightView = rightView
    }

    /// TextFieldView initializer
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    // TODO: add example
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        formatter : Formatter,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() }
    ) {
        self.titleKey = titleKey
        self._text = text
        self.theme = theme
        self.format = .formatter(formatter)

        self.leftView = leftView
        self.rightView = rightView
    }

    // MARK: - View

    public var body: some View {
        self.contentView()
            .scaledFrame(height: self.height)
            .background(self.viewModel.colors.background)
            .allowsHitTesting(!self.isReadOnly)
            .scaledBorder(
                width: self.viewModel.borderLayout.width,
                radius: self.viewModel.borderLayout.radius,
                color: self.viewModel.colors.border
            )
            .opacity(self.viewModel.dim)
            .preference(
                key: TextFieldFocusPreferenceKey.self,
                value: self.isFocused
            )
            .onAppear() {
            self.viewModel.updateAll(
                theme: self.theme,
                intent: self.intent,
                borderStyle: .roundedRect, // TODO:
                isReadOnly: self.isReadOnly,
                clearMode: self.clearMode,
                isFocused: self.isFocused,
                isEnabled: self.isEnabled
            )
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        .onChange(of: self.intent) { intent in
            self.viewModel.intent = intent
        }
        .onChange(of: self.isReadOnly) { isReadOnly in
            self.viewModel.isReadOnly = isReadOnly
        }
        .onChange(of: self.clearMode) { clearMode in
            self.viewModel.clearMode = clearMode
        }
        .onChange(of: self.isFocused) { isFocused in
            self.viewModel.isFocused = isFocused
        }
        .onChange(of: self.isEnabled) { isEnabled in
            self.viewModel.isEnabled = isEnabled
        }
    }

    // MARK: - ViewBuilder

    @ViewBuilder
    private func contentView() -> some View {
        HStack(spacing: self.viewModel.spacings.content) {
            // Left View
            self.leftView()
                .background(.orange)

            // TextField
            self.textField()
                .clearButton(self.$text, viewModel: self.viewModel)
                .focused(self.$isFocused)

            // Right View
            if !self.viewModel.isClearButton {
                self.rightView()
                    .background(.yellow)
            }
        }
        .padding(self.viewModel.contentPadding)
    }

    private func textField() -> some View {
        Group {
            switch (self.isSecureMode, self.format) {
            case (true, _):
                SecureField(
                    self.titleKey,
                    text: self.$text,
                    prompt: self.prompt()
                )
            case (false, .formatter(let formatter)):
                TextField(
                    self.titleKey,
                    value: self.$text,
                    formatter: formatter,
                    prompt: self.prompt()
                )
            default:
                TextField(
                    self.titleKey,
                    text: self.$text,
                    prompt: self.prompt()
                )
            }
        }
        .font(self.viewModel.font)
        .textFieldStyle(.plain)
        .foregroundStyle(self.viewModel.colors.text)
        .tint(self.viewModel.colors.text)
        .accessibilityIdentifier(TextFieldAccessibilityIdentifier.view)
    }

    private func prompt() -> Text {
        Text(self.titleKey).foregroundColor(self.viewModel.colors.placeholder)
    }
}


