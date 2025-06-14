//
//  TextFieldAddons.swift
//  SparkTextField
//
//  Created by louis.borlee on 21/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

/// A Spark TextField that can be surrounded by left and/or right addons
public struct TextFieldAddons<LeftView: View, RightView: View, LeftAddon: View, RightAddon: View>: View {

    // MARK: - Properties

    @ScaledMetric private var maxHeight: CGFloat = TextInputConstants.height
    @ScaledMetric private var scaleFactor: CGFloat = 1.0
    @ObservedObject private var viewModel: TextFieldAddonsViewModel
    private let leftAddon: () -> TextFieldAddon<LeftAddon>
    private let rightAddon: () -> TextFieldAddon<RightAddon>

    @Environment(\.textFieldClearMode) private var clearMode
    @State private var isFocused: Bool = false

    private let titleKey: LocalizedStringKey
    @Binding private var text: String
    private var type: TextFieldViewType
    private let leftView: () -> LeftView
    private let rightView: () -> RightView

    // MARK: - Initialization

    /// TextFieldAddons initializer
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder
    ///   - text: The textfield's text binding
    ///   - theme: The textfield's current theme
    ///   - intent: The textfield's current intent
    ///   - type: The type of field with its associated callback(s), default is `.standard()`
    ///   - isReadOnly: Set this to true if you want the textfield to be readOnly, default is `false`
    ///   - leftView: The TextField's left view, default is `EmptyView`
    ///   - rightView: The TextField's right view, default is `EmptyView`
    ///   - leftAddon: The TextField's left addon, default is `EmptyView`
    ///   - rightAddon: The TextField's right addon, default is `EmptyView`
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        intent: TextInputIntent,
        type: TextFieldViewType = .standard(),
        isReadOnly: Bool,
        leftView: @escaping (() -> LeftView) = { EmptyView() },
        rightView: @escaping (() -> RightView) = { EmptyView() },
        leftAddon: @escaping (() -> TextFieldAddon<LeftAddon>) = { .init(withPadding: false) { EmptyView() } },
        rightAddon: @escaping (() -> TextFieldAddon<RightAddon>) = { .init(withPadding: false) { EmptyView() } }
    ) {
        let viewModel = TextFieldAddonsViewModel(
            theme: theme,
            intent: intent
        )
        self.viewModel = viewModel

        self.titleKey = titleKey
        self._text = text
        self.type = type
        self.leftView = leftView
        self.rightView = rightView
        self.leftAddon = leftAddon
        self.rightAddon = rightAddon

        self.viewModel.textFieldViewModel.isReadOnly = isReadOnly
    }

    // MARK: - Getter

    private func getLeftAddonPadding(withPadding: Bool) -> EdgeInsets {
        guard withPadding else { return .init(all: 0) }
        return .init(
            top: .zero,
            leading: self.viewModel.leftSpacing,
            bottom: .zero,
            trailing: self.viewModel.leftSpacing
        )
    }

    private func getRightAddonPadding(withPadding: Bool) -> EdgeInsets {
        guard withPadding else { return .init(all: 0) }
        return .init(
            top: .zero,
            leading: self.viewModel.rightSpacing,
            bottom: .zero,
            trailing: self.viewModel.rightSpacing
        )
    }

    private func getTextFieldPadding() -> EdgeInsets {
        let showClearButton = self.clearMode.showClearButton(isFocused: self.isFocused)
        return EdgeInsets(
            top: .zero,
            leading: self.viewModel.leftSpacing,
            bottom: .zero,
            trailing: showClearButton ? .zero : self.viewModel.rightSpacing
        )
    }

    // MARK: - View

    public var body: some View {
        ZStack {
            self.viewModel.backgroundColor.color
            HStack(spacing: 0) {
                leftAddonIfNeeded()
                textField()
                    .padding(getTextFieldPadding())
                rightAddonIfNeeded()
            }
        }
        .frame(maxHeight: maxHeight)
        .allowsHitTesting(!self.viewModel.textFieldViewModel.isReadOnly)
        .border(
            width: self.viewModel.borderWidth * self.scaleFactor,
            radius: self.viewModel.borderRadius * self.scaleFactor,
            colorToken: self.viewModel.textFieldViewModel.borderColor
        )
        .opacity(self.viewModel.dim)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(TextFieldAddonsAccessibilityIdentifier.view)
        .onPreferenceChange(TextFieldFocusPreferenceKey.self) { value in
            self.isFocused = value
        }
    }

    // MARK: - ViewBuilder

    @ViewBuilder
    private func leftAddonIfNeeded() -> some View {
        // If the content of leftAddon is EmptyView, it will show nothing
        let leftAddon = self.leftAddon()
        leftAddon
            .padding(getLeftAddonPadding(withPadding: leftAddon.withPadding))
            .overlay(alignment: .trailing) {
                separator()
            }
            .layoutPriority(leftAddon.layoutPriority)
    }

    @ViewBuilder
    private func rightAddonIfNeeded() -> some View {
        // If the content of rightAddon is EmptyView, it will show nothing
        let rightAddon = self.rightAddon()
        rightAddon
            .padding(getRightAddonPadding(withPadding: rightAddon.withPadding))
            .overlay(alignment: .leading) {
                separator()
            }
            .layoutPriority(rightAddon.layoutPriority)
    }

    @ViewBuilder
    private func separator() -> some View {
        self.viewModel.textFieldViewModel.borderColor.color
            .frame(width: self.viewModel.borderWidth * self.scaleFactor,
                   height: maxHeight)
    }

    @ViewBuilder
    private func textField() -> TextFieldView<LeftView, RightView> {
        TextFieldView(titleKey: titleKey, text: $text, viewModel: viewModel.textFieldViewModel, type: type, leftView: leftView, rightView: rightView)
    }
}
