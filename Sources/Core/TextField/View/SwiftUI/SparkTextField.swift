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

// TODO: INFO: avoir un viewModel pour UIKit et un autre pour SwiftUI semble être la meilleur solution.

// TODO: comment


/// A **Spark** control that displays an editable text interface.
///
/// It is possible to display some side views :
/// - leftView (at the left of the textField).
/// - rightView (at the right of the textField)
///
/// And some addons :
/// - leftAddon (at the left of the leftView or textField if there is no leftView)
/// - rightAddon (at the right of the rightView or textField if there is no rightView)
///
/// All theses views are optional. By default all side views are **nil** (corresponding to EmptyView).
///
///
// TODO: add example
// TODO: add screenshot
public struct SparkTextField<LeftView: View, RightView: View, LeftAddon: View, RightAddon: View>: View {

    // MARK: - Properties

    private let theme: Theme
    private let titleKey: LocalizedStringKey
    private let format: TextFieldFormat?

    @Binding private var text: String

    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.textFieldIntent) private var intent
    @Environment(\.textFieldReadOnly) private var isReadOnly
    @Environment(\.textFieldClearMode) private var clearMode
    @Environment(\.textFieldSecureEntry) private var isSecureEntry
    @Environment(\.textFieldLeftAddonConfiguration) private var leftAddonConfiguration
    @Environment(\.textFieldRightAddonConfiguration) private var rightAddonConfiguration

    @FocusState private var isFocused: Bool

    private let leftView: () -> LeftView
    private let rightView: () -> RightView
    private let leftAddon: () -> LeftAddon
    private let rightAddon: () -> RightAddon

    private var height: CGFloat = TextInputConstants.height

    @StateObject private var viewModel = TextFieldViewModel()

    // MARK: - Initialization

    /// SparkTextField initializer.
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    ///   - leftAddon: The textField's left addon, default is `EmptyView`.
    ///   - rightAddon: The textField's right addon, default is `EmptyView`.
    // TODO: add example
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() },
        leftAddon: @escaping () -> LeftAddon = { EmptyView() },
        rightAddon: @escaping () -> RightAddon = { EmptyView() }
    ) {
        self.titleKey = titleKey
        self._text = text
        self.theme = theme
        self.format = nil

        self.leftAddon = leftAddon
        self.leftView = leftView
        self.rightView = rightView
        self.rightAddon = rightAddon
    }

    /// SparkTextField initializer with *formatter*.
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    ///   - leftAddon: The textField's left addon, default is `EmptyView`.
    ///   - rightAddon: The textField's right addon, default is `EmptyView`.
    // TODO: add example
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        formatter: Formatter,
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() },
        leftAddon: @escaping () -> LeftAddon = { EmptyView() },
        rightAddon: @escaping () -> RightAddon = { EmptyView() }
    ) {
        self.titleKey = titleKey
        self._text = text
        self.theme = theme
        self.format = .formatter(formatter)

        self.leftAddon = leftAddon
        self.leftView = leftView
        self.rightView = rightView
        self.rightAddon = rightAddon
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
                colorToken: self.viewModel.colors.border
            )
            .opacity(self.viewModel.dim)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            .accessibilityElement(children: .contain)
            .onAppear() {
                self.viewModel.updateAll(
                    theme: self.theme,
                    intent: self.intent,
                    isReadOnly: self.isReadOnly,
                    clearMode: self.clearMode,
                    leftAddonConfiguration: self.leftAddonConfiguration,
                    rightAddonConfiguration: self.rightAddonConfiguration,
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
            .onChange(of: self.clearMode) { clearMode in
                self.viewModel.clearMode = clearMode
            }
            .onChange(of: self.leftAddonConfiguration) { leftAddonConfiguration in
                self.viewModel.leftAddonConfiguration = leftAddonConfiguration
            }
            .onChange(of: self.rightAddonConfiguration) { rightAddonConfiguration in
                self.viewModel.rightAddonConfiguration = rightAddonConfiguration
            }
            .onChange(of: self.isFocused) { isFocused in
                self.viewModel.isFocused = isFocused
            }
            .onChange(of: self.isEnabled) { isEnabled in
                self.viewModel.isEnabled = isEnabled
            }
    }

    // MARK: - Subviews

    private func contentView() -> some View {
        HStack(spacing: .zero) {
            // Left Addon
            self.leftAddon()
                .scaledPadding(self.viewModel.leftAddonPadding)
                .layoutPriority(self.leftAddonConfiguration.layoutPriority)

            // Separator
            if self.leftAddonConfiguration.hasSeparator {
                self.separator()
            }

            ScaledHStack(spacing: self.viewModel.spacings.content) {
                // Left View
                self.leftView()

                HStack(spacing: 0) {
                    // TextField
                    self.textField()
                        .font(self.viewModel.font)
                        .textFieldStyle(.plain)
                        .foregroundStyle(self.viewModel.colors.text)
                        .tint(self.viewModel.colors.text)
                        .clearButton(self.$text, viewModel: self.viewModel)
                        .frame(maxHeight: .infinity)
                        .scaledPadding(.trailing, self.viewModel.contentPadding.inputTrailing)
                        .focused(self.$isFocused)
                        .accessibilityIdentifier(TextFieldAccessibilityIdentifier.view)

                    // Right View
                    self.rightView()
                        .scaledPadding(.trailing, self.viewModel.contentPadding.trailing)
                }
            }
            .scaledPadding(.top, self.viewModel.contentPadding.top)
            .scaledPadding(.bottom, self.viewModel.contentPadding.bottom)
            .scaledPadding(.leading, self.viewModel.contentPadding.leading)

            // Separator
            if self.rightAddonConfiguration.hasSeparator {
                self.separator()
            }

            // Right Addon
            self.rightAddon()
                .scaledPadding(self.viewModel.rightAddonPadding)
                .layoutPriority(self.rightAddonConfiguration.layoutPriority)
        }
    }

    @ViewBuilder
    private func textField() -> some View {
        switch (self.isSecureEntry, self.format) {
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

    private func prompt() -> Text {
        Text(self.titleKey).foregroundColor(self.viewModel.colors.placeholder)
    }

    private func separator() -> some View {
        Divider()
            .scaledFrame(width: self.viewModel.borderLayout.width)
            .overlay(self.viewModel.colors.border)
    }
}
