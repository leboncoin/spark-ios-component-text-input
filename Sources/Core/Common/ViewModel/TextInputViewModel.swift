//
//  TextInputViewModel.swift
//  Spark
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
@_spi(SI_SPI) import SparkCommon
import SparkTheming

class TextInputViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var borderLayout: TextInputBorderLayout
    @Published private(set) var colors: TextInputColors
    @Published private(set) var dim: CGFloat
    @Published private(set) var font: any TypographyFontToken
    @Published private(set) var isClearButton: Bool
    @Published private(set) var spacings: TextInputSpacings

    // MARK: - Properties

    var theme: Theme {
        didSet {
            self.setColors()
            self.setBorderLayout()
            self.setSpacings()
            self.setDim()
            self.setFont()
        }
    }

    var intent: TextInputIntent = .default {
        didSet {
            guard oldValue != self.intent else { return }
            self.setColors()
        }
    }

    var borderStyle: TextInputBorderStyle = .default {
        didSet {
            guard oldValue != self.borderStyle else { return }
            self.setBorderLayout()
            self.setSpacings()
        }
    }

    var clearMode: TextFieldClearMode = .default {
        didSet {
            guard oldValue != self.clearMode else { return }
            self.setIsClearButton()
        }
    }

    var isFocused: Bool = false { // TODO: put in constant
        didSet {
            guard oldValue != self.isFocused else { return }
            self.setColors()
            self.setBorderLayout()
            self.setIsClearButton()
        }
    }

    var isEnabled: Bool = true { // TODO: put in constant
        didSet {
            guard oldValue != self.isEnabled else { return }
            self.setColors()
            self.setDim()
        }
    }

    var isReadOnly: Bool = false { // TODO: put in constant
        didSet {
            guard oldValue != self.isReadOnly else { return }
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

    // MARK: - Initialization

    init(
        theme: Theme,
        getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable = TextInputGetBorderLayoutUseCase(),
        getColorsUseCase: any TextInputGetColorsUseCasable = TextInputGetColorsUseCase(),
        getDimUseCase: any TextInputGetDimUseCaseable = TextInputGetDimUseCase(),
        getFontUseCase: any TextInputGetFontUseCaseable = TextInputGetFontUseCase(),
        getIsClearButtonUseCase: any TextFieldGetIsClearButtonUseCaseable = TextFieldGetIsClearButtonUseCase(),
        getSpacingsUseCase: any TextInputGetSpacingsUseCasable = TextInputGetSpacingsUseCase()
    ) {
        self.theme = theme

        self.getBorderLayoutUseCase = getBorderLayoutUseCase
        self.getColorsUseCase = getColorsUseCase
        self.getDimUseCase = getDimUseCase
        self.getFontUseCase = getFontUseCase
        self.getIsClearButtonUseCase = getIsClearButtonUseCase
        self.getSpacingsUseCase = getSpacingsUseCase

        self.borderLayout = getBorderLayoutUseCase.execute(
            theme: theme,
            borderStyle: self.borderStyle,
            isFocused: self.isFocused)

        self.colors = getColorsUseCase.execute(
            theme: theme,
            intent: intent,
            isFocused: self.isFocused,
            isEnabled: self.isEnabled,
            isReadOnly: self.isReadOnly
        )

        self.dim = getDimUseCase.execute(
            theme: theme,
            isEnabled: self.isEnabled
        )

        self.font = getFontUseCase.execute(theme: theme)

        self.isClearButton = getIsClearButtonUseCase.execute(
            clearMode: self.clearMode,
            isFocused: self.isFocused
        )

        self.spacings = getSpacingsUseCase.execute(
            theme: theme,
            borderStyle: self.borderStyle
        )
    }

    // MARK: - Private & Internal Setter

    private func setColors() {
        self.colors = self.getColorsUseCase.execute(
            theme: self.theme,
            intent: self.intent,
            isFocused: self.isFocused,
            isEnabled: self.isEnabled,
            isReadOnly: self.isReadOnly
        )
    }

    private func setBorderLayout() {
        self.borderLayout = self.getBorderLayoutUseCase.execute(
            theme: self.theme,
            borderStyle: self.borderStyle,
            isFocused: self.isFocused
        )
    }

    private func setIsClearButton() {
        self.isClearButton = self.getIsClearButtonUseCase.execute(
            clearMode: self.clearMode,
            isFocused: self.isFocused
        )
    }

    private func setSpacings() {
        self.spacings = self.getSpacingsUseCase.execute(
            theme: self.theme,
            borderStyle: self.borderStyle
        )
    }

    private func setDim() {
        self.dim = self.getDimUseCase.execute(
            theme: self.theme,
            isEnabled: self.isEnabled
        )
    }

    private func setFont() {
        self.font = self.getFontUseCase.execute(theme: self.theme)
    }
}
