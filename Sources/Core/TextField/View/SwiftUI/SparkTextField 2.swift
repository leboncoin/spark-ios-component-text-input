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
// TODO:

// TODO: INFO: avoir un viewModel pour UIKit et un autre pour SwiftUI semble être la meilleur solution.

public struct SparkTextField2<LeftView: View, RightView: View>: View {

    // MARK: - Properties

    @ScaledMetric private var height: CGFloat = TextInputConstants.height

    @Binding private var text: String

    @State var textFieldID: String = UUID().uuidString
    @FocusState private var isFocused: Bool

    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.textFieldIntent) private var intent
    @Environment(\.textFieldReadOnly) private var isReadOnly
    @Environment(\.textFieldClearMode) private var clearMode

    private let titleKey: LocalizedStringKey
    private var type: TextFieldViewType

    private let leftView: () -> LeftView
    private let rightView: () -> RightView

    private let theme: Theme

    @StateObject private var configuration = TextFieldConfiguration()

    // MARK: - Initialization

    /// TextFieldView initializer
    /// - Parameters:
    ///   - titleKey: The textfield's current placeholder.
    ///   - text: The textfield's text binding.
    ///   - theme: The textfield's current theme.
    ///   - type: The type of field with its associated callback(s), default is `.standard()`.
    ///   - leftView: The textField's left view, default is `EmptyView`.
    ///   - rightView: The textField's right view, default is `EmptyView`.
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        theme: Theme,
        type: TextFieldViewType = .standard(),
        leftView: @escaping () -> LeftView = { EmptyView() },
        rightView: @escaping () -> RightView = { EmptyView() }
    ) {
        self.titleKey = titleKey
        self._text = text
        self.type = type

        self.leftView = leftView
        self.rightView = rightView

        self.theme = theme
    }

    // MARK: - View

    public var body: some View {
        ZStack {
            self.configuration.colors.background
            self.contentView()
        }
        .tint(self.configuration.colors.text)
        .allowsHitTesting(!self.isReadOnly)
        .scaledBorder(
            width: self.configuration.borderLayout.width,
            radius: self.configuration.borderLayout.radius,
            color: self.configuration.colors.border
        )
        .frame(height: self.height) // TODO: use scaled frame
        .opacity(self.configuration.dim)
        .preference(
            key: TextFieldFocusPreferenceKey.self,
            value: self.isFocused
        )
        .onAppear() {
            self.configuration.updateAll(
                theme: self.theme,
                intent: self.intent,
                borderStyle: .roundedRect, // TODO:
                isReadOnly: self.isReadOnly,
                clearMode: self.clearMode,
                isFocused: self.isFocused,
                isEnabled: self.isEnabled
            )
        }
        .onChange(of: self.intent) { intent in
            self.configuration.intent = intent
        }
        .onChange(of: self.isReadOnly) { isReadOnly in
            self.configuration.isReadOnly = isReadOnly
        }
        .onChange(of: self.clearMode) { clearMode in
            self.configuration.clearMode = clearMode
        }
        .onChange(of: self.isFocused) { isFocused in
            self.configuration.isFocused = isFocused
        }
        .onChange(of: self.isEnabled) { isEnabled in
            self.configuration.isEnabled = isEnabled
        }
    }

    // MARK: - ViewBuilder

    @ViewBuilder
    private func contentView() -> some View {
        HStack(spacing: self.configuration.spacings.content) {
            // Left View
            self.leftView()

            HStack(spacing: self.configuration.subContentSpacing) {
                // TextField
                self.textField()
                    .focused(self.$isFocused)
                    .id(self.textFieldID)

                // Clear Button
                if self.configuration.isClearButton {
                    ClearButton(
                        text: self.$text,
                        textFieldID: self.$textFieldID
                    )
                } else {
                    // Right View
                    self.rightView()
                }
            }
        }
        .padding(self.configuration.contentPadding)
    }

    @ViewBuilder
    private func textField() -> some View {
        Group {
            switch type {
            case .secure(let onCommit):
                // TODO: add prompt for the placeholder like the TextEditor
                SecureField(
                    self.titleKey,
                    text: self.$text,
                    prompt: Text(self.titleKey).foregroundColor(self.configuration.colors.text)
                )
            case .standard(let onEditingChanged, let onCommit):
                // TODO: Format
                // TODO: Formatter
                // TODO: add prompt for the placeholder like the TextEditor
                TextField(self.titleKey, text: self.$text)
            }
        }
        .font(self.configuration.font)
        .textFieldStyle(.plain)
        .foregroundStyle(self.configuration.colors.text)
        .accessibilityIdentifier(TextFieldAccessibilityIdentifier.view)
    }
}

private class TextFieldConfiguration: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var borderLayout = TextInputBorderLayout()
    @Published private(set) var colors = TextInputColorsTemp()
    @Published private(set) var dim: CGFloat = 1 // TODO: Constant
    @Published private(set) var font: Font = .body // TODO: constants
    @Published private(set) var isClearButton: Bool = false { // TODO: constants
        didSet {
            self.setContentPadding()
            self.setSubContentSpacing()
        }
    }
    @Published private(set) var spacings = TextInputSpacings() {
        didSet {
            self.setContentPadding()
            self.setSubContentSpacing()
        }
    }
    @Published private(set) var contentPadding: EdgeInsets = .init()
    @Published private(set) var subContentSpacing: CGFloat = 0 // TODO: COnstants

    // MARK: - Properties

    private var alreadyUpdateAll = false

    var theme: (any Theme)? {
        didSet {
            guard self.alreadyUpdateAll else { return }

            self.setColors()
            self.setBorderLayout()
            self.setSpacings()
            self.setDim()
            self.setFont()
        }
    }

    var intent: TextInputIntent? {
        didSet {
            guard oldValue != self.intent, self.alreadyUpdateAll else { return }
            self.setColors()
        }
    }

    var borderStyle: TextInputBorderStyle? {
        didSet {
            guard oldValue != self.borderStyle, self.alreadyUpdateAll else { return }
            self.setBorderLayout()
            self.setSpacings()
        }
    }

    var clearMode: TextFieldClearMode? {
        didSet {
            guard oldValue != self.clearMode, self.alreadyUpdateAll else { return }
            self.setIsClearButton()
        }
    }

    var isFocused: Bool? {
        didSet {
            guard oldValue != self.isFocused, self.alreadyUpdateAll else { return }
            self.setColors()
            self.setBorderLayout()
            self.setIsClearButton()
        }
    }

    var isEnabled: Bool? {
        didSet {
            guard oldValue != self.isEnabled, self.alreadyUpdateAll else { return }
            self.setColors()
            self.setDim()
        }
    }

    var isReadOnly: Bool? {
        didSet {
            guard oldValue != self.isReadOnly, self.alreadyUpdateAll else { return }
            self.setColors()
        }
    }

    // MARK: - Use Case Properties

    private let getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable
    private let getColorsUseCase: any TextInputGetColorsUseCasable
    private let getDimUseCase: any TextInputGetDimUseCaseable
    private let getFontUseCase: any TextInputGetFontUseCaseable
    private let getIsClearButtonUseCase: any TextFieldGetIsClearButtonUseCaseable
    private let getSpacingsUseCase: any TextInputGetSpacingsUseCasable
    private let getContentPaddingUseCaseable: any TextFieldGetContentPaddingUseCaseable
    private let getSubContentSpacingUseCase: any TextFieldGetSubContentSpacingUseCaseable

    // MARK: - Initialization

    init(
        getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable = TextInputGetBorderLayoutUseCase(),
        getColorsUseCase: any TextInputGetColorsUseCasable = TextInputGetColorsUseCase(),
        getDimUseCase: any TextInputGetDimUseCaseable = TextInputGetDimUseCase(),
        getFontUseCase: any TextInputGetFontUseCaseable = TextInputGetFontUseCase(),
        getIsClearButtonUseCase: any TextFieldGetIsClearButtonUseCaseable = TextFieldGetIsClearButtonUseCase(),
        getSpacingsUseCase: any TextInputGetSpacingsUseCasable = TextInputGetSpacingsUseCase(),
        getContentPaddingUseCaseable: any TextFieldGetContentPaddingUseCaseable = TextFieldGetContentPaddingUseCase(),
        getSubContentSpacingUseCase: any TextFieldGetSubContentSpacingUseCaseable = TextFieldGetSubContentSpacingUseCase()
    ) {
        self.getBorderLayoutUseCase = getBorderLayoutUseCase
        self.getColorsUseCase = getColorsUseCase
        self.getDimUseCase = getDimUseCase
        self.getFontUseCase = getFontUseCase
        self.getIsClearButtonUseCase = getIsClearButtonUseCase
        self.getSpacingsUseCase = getSpacingsUseCase
        self.getContentPaddingUseCaseable = getContentPaddingUseCaseable
        self.getSubContentSpacingUseCase = getSubContentSpacingUseCase
    }

    func updateAll(
        theme: Theme,
        intent: TextInputIntent,
        borderStyle: TextInputBorderStyle,
        isReadOnly: Bool,
        clearMode: TextFieldClearMode,
        isFocused: Bool,
        isEnabled: Bool
    ) {
        self.theme = theme
        self.intent = intent
        self.borderStyle = borderStyle
        self.isReadOnly = isReadOnly
        self.clearMode = clearMode
        self.isFocused = isFocused
        self.isEnabled = isEnabled

        self.setColors()
        self.setBorderLayout()
        self.setIsClearButton()
        self.setSpacings()
        self.setDim()
        self.setFont()

        self.alreadyUpdateAll = true
    }

    // MARK: - Private Setter

    private func setColors() {
        guard let theme,
              let intent,
              let isFocused,
              let isEnabled,
              let isReadOnly else {
            return
        }

        self.colors = self.getColorsUseCase.execute(
            theme: theme,
            intent: intent,
            isFocused: isFocused,
            isEnabled: isEnabled,
            isReadOnly: isReadOnly
        ).convert()
    }

    private func setBorderLayout() {
        guard let theme, let borderStyle, let isFocused else {
            return
        }

        self.borderLayout = self.getBorderLayoutUseCase.execute(
            theme: theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )
    }

    private func setIsClearButton() {
        guard let clearMode, let isFocused else {
            return
        }

        self.isClearButton = self.getIsClearButtonUseCase.execute(
            clearMode: clearMode,
            isFocused: isFocused
        )
    }

    private func setSpacings() {
        guard let theme, let borderStyle else {
            return
        }

        self.spacings = self.getSpacingsUseCase.execute(
            theme: theme,
            borderStyle: borderStyle
        )
    }

    private func setContentPadding() {
        self.contentPadding = self.getContentPaddingUseCaseable.execute(
            spacings: self.spacings,
            isClearButton: self.isClearButton
        )
    }

    private func setSubContentSpacing() {
        self.subContentSpacing = self.getSubContentSpacingUseCase.execute(
            spacings: self.spacings,
            isClearButton: self.isClearButton
        )
    }

    private func setDim() {
        guard let theme, let isEnabled else {
            return
        }

        self.dim = self.getDimUseCase.execute(
            theme: theme,
            isEnabled: isEnabled
        )
    }

    private func setFont() {
        guard let theme else {
            return
        }

        self.font = self.getFontUseCase.execute(theme: theme).font
    }
}
