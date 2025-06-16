//
//  TextFieldViewModel.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 16/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI
@_spi(SI_SPI) import SparkCommon
import SparkTheming

/// UseCase only used by **SwiftUI** View.
internal final class TextFieldViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var borderLayout = TextInputBorderLayout()
    @Published private(set) var colors = TextInputColorsTemp()
    @Published private(set) var dim: CGFloat = 1 // TODO: Constant
    @Published private(set) var font: Font = .body // TODO: constants
    @Published private(set) var isClearButton: Bool = false { // TODO: constants
        didSet {
            self.setContentPadding()
        }
    }
    @Published private(set) var spacings = TextInputSpacings() {
        didSet {
            self.setContentPadding()
        }
    }
    @Published private(set) var contentPadding: EdgeInsets = .init()

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
    private let getContentPaddingUseCase: any TextFieldGetContentPaddingUseCaseable

    // MARK: - Initialization

    init(
        getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable = TextInputGetBorderLayoutUseCase(),
        getColorsUseCase: any TextInputGetColorsUseCasable = TextInputGetColorsUseCase(),
        getDimUseCase: any TextInputGetDimUseCaseable = TextInputGetDimUseCase(),
        getFontUseCase: any TextInputGetFontUseCaseable = TextInputGetFontUseCase(),
        getIsClearButtonUseCase: any TextFieldGetIsClearButtonUseCaseable = TextFieldGetIsClearButtonUseCase(),
        getSpacingsUseCase: any TextInputGetSpacingsUseCasable = TextInputGetSpacingsUseCase(),
        getContentPaddingUseCase: any TextFieldGetContentPaddingUseCaseable = TextFieldGetContentPaddingUseCase()
    ) {
        self.getBorderLayoutUseCase = getBorderLayoutUseCase
        self.getColorsUseCase = getColorsUseCase
        self.getDimUseCase = getDimUseCase
        self.getFontUseCase = getFontUseCase
        self.getIsClearButtonUseCase = getIsClearButtonUseCase
        self.getSpacingsUseCase = getSpacingsUseCase
        self.getContentPaddingUseCase = getContentPaddingUseCase
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
        self.contentPadding = self.getContentPaddingUseCase.execute(
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
