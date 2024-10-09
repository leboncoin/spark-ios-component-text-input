//
//  TextInputViewModel.swift
//  Spark
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
@_spi(SI_SPI) import SparkCommon
import SparkTheming

class TextInputViewModel: ObservableObject {

    // MARK: - Published Properties

    // Colors
    @Published private(set) var textColor: any ColorToken
    @Published private(set) var placeholderColor: any ColorToken
    @Published var borderColor: any ColorToken
    @Published var backgroundColor: any ColorToken

    // BorderLayout
    @Published private(set) var borderRadius: CGFloat
    @Published private(set) var borderWidth: CGFloat

    // Spacings
    @Published private(set) var leftSpacing: CGFloat
    @Published private(set) var contentSpacing: CGFloat
    @Published private(set) var rightSpacing: CGFloat

    @Published var dim: CGFloat

    @Published private(set) var font: any TypographyFontToken

    // MARK: - Properties

    let getColorsUseCase: any TextInputGetColorsUseCasable
    let getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable
    let getSpacingsUseCase: any TextInputGetSpacingsUseCasable

    var theme: Theme {
        didSet {
            self.setColors()
            self.setBorderLayout()
            self.setSpacings()
            self.setDim()
            self.setFont()
        }
    }
    var intent: TextInputIntent {
        didSet {
            guard oldValue != self.intent else { return }
            self.setColors()
        }
    }

    var isFocused: Bool = false {
        didSet {
            guard oldValue != self.isFocused else { return }
            self.setColors()
            self.setBorderLayout()
        }
    }

    var isEnabled: Bool = true {
        didSet {
            guard oldValue != self.isEnabled else { return }
            self.setColors()
            self.setDim()
        }
    }

    var isUserInteractionEnabled: Bool = true {
        didSet {
            guard oldValue != self.isUserInteractionEnabled else { return }
            self.setColors()
        }
    }

    // MARK: - Initialization

    init(
        theme: Theme,
        intent: TextInputIntent,
        getColorsUseCase: any TextInputGetColorsUseCasable = TextInputGetColorsUseCase(),
        getBorderLayoutUseCase: any TextInputGetBorderLayoutUseCasable = TextInputGetBorderLayoutUseCase(),
        getSpacingsUseCase: any TextInputGetSpacingsUseCasable = TextInputGetSpacingsUseCase()
    ) {
        self.theme = theme
        self.intent = intent

        self.getColorsUseCase = getColorsUseCase
        self.getBorderLayoutUseCase = getBorderLayoutUseCase
        self.getSpacingsUseCase = getSpacingsUseCase

        // Colors
        let colors = getColorsUseCase.execute(
            theme: theme,
            intent: intent,
            isFocused: self.isFocused,
            isEnabled: self.isEnabled,
            isUserInteractionEnabled: self.isUserInteractionEnabled
        )
        self.textColor = colors.text
        self.placeholderColor = colors.placeholder
        self.borderColor = colors.border
        self.backgroundColor = colors.background

        // BorderLayout
        let borderLayout = getBorderLayoutUseCase.execute(
            theme: theme,
            isFocused: self.isFocused)
        self.borderWidth = borderLayout.width
        self.borderRadius = borderLayout.radius

        // Spacings
        let spacings = getSpacingsUseCase.execute(theme: theme)
        self.leftSpacing = spacings.left
        self.contentSpacing = spacings.content
        self.rightSpacing = spacings.right

        self.dim = theme.dims.none

        self.font = theme.typography.body1
    }

    // MARK: - Setter

    func setColors() {
        // Colors
        let colors = self.getColorsUseCase.execute(
            theme: self.theme,
            intent: self.intent,
            isFocused: self.isFocused,
            isEnabled: self.isEnabled,
            isUserInteractionEnabled: self.isUserInteractionEnabled
        )
        self.textColor = colors.text
        self.placeholderColor = colors.placeholder
        self.borderColor = colors.border
        self.backgroundColor = colors.background
    }

    func setBorderLayout() {
        let borderLayout = self.getBorderLayoutUseCase.execute(
            theme: self.theme,
            isFocused: self.isFocused
        )
        self.borderWidth = borderLayout.width
        self.borderRadius = borderLayout.radius
    }

    func setSpacings() {
        let spacings = self.getSpacingsUseCase.execute(theme: self.theme)
        self.leftSpacing = spacings.left
        self.contentSpacing = spacings.content
        self.rightSpacing = spacings.right
    }

    func setDim() {
        self.dim = self.isEnabled ? self.theme.dims.none : self.theme.dims.dim3
    }

    private func setFont() {
        self.font = self.theme.typography.body1
    }
}
