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

public struct SparkTextField<LeftView: View, RightView: View>: View {

    // MARK: - Properties

    @ScaledMetric private var height: CGFloat = TextInputConstants.height

    @ObservedObject private var viewModel: TextInputViewModel
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

    @State private var borderLayout = TextInputBorderLayout()
    @State private var colors = TextInputColorsTemp()
    @State private var dim: CGFloat = 1 // TODO: Constant
    @State private var font: Font = .body // TODO: constants
    @State private var isClearButton: Bool = false // TODO: constants
    @State private var spacings = TextInputSpacings()

    private let theme: Theme
    private let configuration = TextFieldConfiguration()

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
        self.viewModel = .init(theme: theme)

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
            self.colors.background
            self.contentView()
        }
        .tint(self.colors.text)
        .allowsHitTesting(!self.isReadOnly)
        .scaledBorder(
            width: self.borderLayout.width,
            radius: self.borderLayout.radius,
            color: self.colors.border
        )
        .frame(height: self.height) // TODO: use scaled frame
        .opacity(self.dim)
        .preference(
            key: TextFieldFocusPreferenceKey.self,
            value: self.isFocused
        )
        .onAppear() {
            let properties = self.configuration.all(
                theme: self.theme,
                intent: self.intent,
                borderStyle: .roundedRect, // TODO:
                isReadOnly: self.isReadOnly,
                clearMode: self.clearMode,
                isFocused: self.isFocused,
                isEnabled: self.isEnabled
            )

            self.borderLayout = properties.borderLayout
            self.colors = properties.colors
            self.dim = properties.dim
            self.font = properties.font
            self.isClearButton = properties.isClearButton
            self.spacings = properties.spacings
        }
        .onChange(of: self.intent) { intent in
            print("LOGROB Intent changed: \(intent)")
            self.viewModel.intent = intent
        }
        .onChange(of: self.isReadOnly) { isReadOnly in
                print("LOGROB isReadOnly changed: \(isReadOnly)")
            self.viewModel.isReadOnly = isReadOnly
        }
        .onChange(of: self.clearMode) { clearMode in
            print("LOGROB clearMode changed: \(clearMode)")
            self.viewModel.clearMode = clearMode
        }
        .onChange(of: self.isFocused) { isFocused in
            print("LOGROB isFocused changed: \(isFocused)")
            self.viewModel.isFocused = isFocused

            self.borderLayout = self.configuration.borderStyle(
                theme: self.theme,
                borderStyle: .roundedRect,
                isFocused: isFocused
            )
        }
        .onChange(of: self.isEnabled) { isEnabled in
            print("LOGROB isEnabled changed: \(isEnabled)")
            self.viewModel.isEnabled = isEnabled
        }
    }

    // MARK: - ViewBuilder

    @ViewBuilder
    private func contentView() -> some View {
        HStack(spacing: self.spacings.content) {
            // Left View
            self.leftView()

            HStack(spacing: self.isClearButton ? .zero : self.spacings.content) {
                // TextField
                self.textField()
                    .focused(self.$isFocused)
                    .id(self.textFieldID)

                // Clear Button
                if self.isClearButton {
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
        .padding(.init(
            top: .zero,
            leading: self.spacings.left,
            bottom: .zero,
            trailing: self.isClearButton ? .zero : self.spacings.right
        ))
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
                    prompt: Text(self.titleKey).foregroundColor(self.colors.text)
                )
            case .standard(let onEditingChanged, let onCommit):
                // TODO: Format
                // TODO: Formatter
                // TODO: add prompt for the placeholder like the TextEditor
                TextField(self.titleKey, text: self.$text)
            }
        }
        .font(self.font)
        .textFieldStyle(.plain)
        .foregroundStyle(self.colors.text)
        .accessibilityIdentifier(TextFieldAccessibilityIdentifier.view)
    }
}

private struct TextFieldConfiguration {

    struct All {
        let borderLayout: TextInputBorderLayout
        let colors: TextInputColorsTemp
        let dim: CGFloat
        let font: Font
        let isClearButton: Bool
        let spacings: TextInputSpacings
        let value: Int
    }

    // MARK: - Use Case Properties

    private let getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable
    private let getColorsUseCase: any TextInputGetColorsUseCasable
    private let getDimUseCase: any TextInputGetDimUseCaseable
    private let getFontUseCase: any TextInputGetFontUseCaseable
    private let getIsClearButtonUseCase: any TextFieldGetIsClearButtonUseCaseable
    private let getSpacingsUseCase: any TextInputGetSpacingsUseCasable

    // MARK: - Initialization

    init(
        getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable = TextInputGetBorderLayoutUseCase(),
        getColorsUseCase: any TextInputGetColorsUseCasable = TextInputGetColorsUseCase(),
        getDimUseCase: any TextInputGetDimUseCaseable = TextInputGetDimUseCase(),
        getFontUseCase: any TextInputGetFontUseCaseable = TextInputGetFontUseCase(),
        getIsClearButtonUseCase: any TextFieldGetIsClearButtonUseCaseable = TextFieldGetIsClearButtonUseCase(),
        getSpacingsUseCase: any TextInputGetSpacingsUseCasable = TextInputGetSpacingsUseCase()
    ) {
        self.getBorderLayoutUseCase = getBorderLayoutUseCase
        self.getColorsUseCase = getColorsUseCase
        self.getDimUseCase = getDimUseCase
        self.getFontUseCase = getFontUseCase
        self.getIsClearButtonUseCase = getIsClearButtonUseCase
        self.getSpacingsUseCase = getSpacingsUseCase
    }

    func all(
        theme: Theme,
        intent: TextInputIntent,
        borderStyle: TextInputBorderStyle,
        isReadOnly: Bool,
        clearMode: TextFieldClearMode,
        isFocused: Bool,
        isEnabled: Bool
    ) -> All {
        let borderLayout = getBorderLayoutUseCase.execute(
            theme: theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )

        let colors = getColorsUseCase.execute(
            theme: theme,
            intent: intent,
            isFocused: isFocused,
            isEnabled: isEnabled,
            isReadOnly: isReadOnly
        )

        let dim = getDimUseCase.execute(
            theme: theme,
            isEnabled: isEnabled
        )

        let fontToken = getFontUseCase.execute(theme: theme)

        let isClearButton = getIsClearButtonUseCase.execute(
            clearMode: clearMode,
            isFocused: isFocused
        )

        let spacings = getSpacingsUseCase.execute(
            theme: theme,
            borderStyle: borderStyle
        )

        return .init(
            borderLayout: borderLayout,
            colors: colors.convert(),
            dim: dim,
            font: fontToken.font,
            isClearButton: isClearButton,
            spacings: spacings,
            value: 2
        )
    }

    func borderStyle(
        theme: any Theme,
        borderStyle: TextInputBorderStyle,
        isFocused: Bool
    ) -> TextInputBorderLayout {
        return self.getBorderLayoutUseCase.execute(
            theme: theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )
    }

    func test(value: Int, isInit: Bool = false) {
        print("LOGROB Value test: \(value) - is init \(isInit)")
    }
}
