//
//  TextInputViewModelTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import XCTest
import Combine
import UIKit
import SwiftUI
@testable import SparkTextInput
@_spi(SI_SPI) @testable import SparkTextInputTesting
@_spi(SI_SPI) import SparkCommonTesting
@_spi(SI_SPI) import SparkThemingTesting
import SparkTheming

final class TextInputViewModelTests: XCTestCase {

    // MARK: - Properties

    var theme: ThemeGeneratedMock!
    var publishers: TextFieldPublishers!
    var getColorsUseCase: TextInputGetColorsUseCasableGeneratedMock!
    var getBorderLayoutUseCase: TextInputGetBorderLayoutUseCasableGeneratedMock!
    var getSpacingsUseCase: TextInputGetSpacingsUseCasableGeneratedMock!
    private var viewModel: TextInputViewModel!

    let intent = TextInputIntent.success
    let borderStyle = TextInputBorderStyle.roundedRect

    var expectedColors: TextFieldColors!
    var expectedBorderLayout: TextInputBorderLayout!
    var expectedSpacings: TextInputSpacings!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        self.theme = ThemeGeneratedMock.mocked()

        self.expectedColors = .mocked(
            text: .blue(),
            placeholder: .green(),
            border: .yellow(),
            background: .purple()
        )
        self.expectedBorderLayout = .mocked(radius: 1, width: 2)
        self.expectedSpacings = .mocked(left: 1, content: 2, right: 3)

        self.getColorsUseCase = .mocked(returnedColors: self.expectedColors)
        self.getBorderLayoutUseCase = .mocked(returnedBorderLayout: self.expectedBorderLayout)
        self.getSpacingsUseCase = .mocked(returnedSpacings: self.expectedSpacings)
        self.viewModel = .init(
            theme: self.theme,
            intent: self.intent,
            borderStyle: self.borderStyle,
            getColorsUseCase: self.getColorsUseCase,
            getBorderLayoutUseCase: self.getBorderLayoutUseCase,
            getSpacingsUseCase: self.getSpacingsUseCase
        )

        self.setupPublishers()
    }

    // MARK: - init
    func test_init() throws {
        // GIVEN / WHEN - Inits from setUp()
        // THEN - Simple variables
        XCTAssertIdentical(self.viewModel.theme as? ThemeGeneratedMock, self.theme, "Wrong theme")
        XCTAssertEqual(self.viewModel.intent, self.intent, "Wrong intent")
        XCTAssertEqual(self.viewModel.borderStyle, self.borderStyle, "Wrong borderStyle")
        XCTAssertTrue(self.viewModel.isEnabled, "Wrong isEnabled")
        XCTAssertFalse(self.viewModel.isReadOnly, "Wrong isReadOnly")
        XCTAssertFalse(self.viewModel.isFocused, "Wrong isFocused")
        XCTAssertEqual(self.viewModel.dim, self.theme.dims.none, "Wrong dim")
        XCTAssertIdentical(self.viewModel.font as? TypographyFontTokenGeneratedMock, self.theme.typography.body1 as? TypographyFontTokenGeneratedMock, "Wrong font")

        // THEN - Colors
        XCTAssertEqual(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCallsCount, 1, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should have been called once")
        let getColorsReceivedArguments = try XCTUnwrap(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReceivedArguments, "Couldn't unwrap getColorsReceivedArguments")
        XCTAssertIdentical(getColorsReceivedArguments.theme as? ThemeGeneratedMock, self.theme, "Wrong getColorsReceivedArguments.theme")
        XCTAssertEqual(getColorsReceivedArguments.intent, self.intent, "Wrong getColorsReceivedArguments.intent")
        XCTAssertFalse(getColorsReceivedArguments.isFocused, "Wrong getColorsReceivedArguments.isFocused")
        XCTAssertTrue(getColorsReceivedArguments.isEnabled, "Wrong getColorsReceivedArguments.isEnabled")
        XCTAssertFalse(getColorsReceivedArguments.isReadOnly, "Wrong getColorsReceivedArguments.isReadOnly")
        XCTAssertTrue(self.viewModel.textColor.equals(self.expectedColors.text), "Wrong textColor")
        XCTAssertTrue(self.viewModel.placeholderColor.equals(self.expectedColors.placeholder), "Wrong placeholderColor")
        XCTAssertTrue(self.viewModel.borderColor.equals(self.expectedColors.border), "Wrong borderColor")
        XCTAssertTrue(self.viewModel.backgroundColor.equals(self.expectedColors.background), "Wrong backgroundColor")

        // THEN - Border Layout
        XCTAssertEqual(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCallsCount, 1, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should have been called once")
        let getBorderLayoutReceivedArguments = try XCTUnwrap(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReceivedArguments, "Couldn't unwrap getBorderLayoutReceivedArguments")
        XCTAssertIdentical(getBorderLayoutReceivedArguments.theme as? ThemeGeneratedMock, self.theme, "Wrong getBorderLayoutReceivedArguments.theme")
        XCTAssertEqual(getBorderLayoutReceivedArguments.borderStyle, .roundedRect, "Wrong getBorderLayoutReceivedArguments.borderStyle")
        XCTAssertFalse(getBorderLayoutReceivedArguments.isFocused, "Wrong getBorderLayoutReceivedArguments.isFocused")
        XCTAssertEqual(self.viewModel.borderWidth, self.expectedBorderLayout.width, "Wrong borderWidth")
        XCTAssertEqual(self.viewModel.borderRadius, self.expectedBorderLayout.radius, "Wrong borderRadius")

        // THEN - Spacings
        XCTAssertEqual(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCallsCount, 1, "getSpacingsUseCase.executeWithThemeAndBorderStyle should have been called once")
        let getSpacingsUseCaseReceivedArguments = try XCTUnwrap(self.getSpacingsUseCase.executeWithThemeAndBorderStyleReceivedArguments, "Couldn't unwrap getSpacingsUseCaseReceivedArguments")
        XCTAssertIdentical(getSpacingsUseCaseReceivedArguments.theme as? ThemeGeneratedMock, self.theme, "Wrong getSpacingsUseCaseReceivedArguments.theme")
        XCTAssertEqual(getSpacingsUseCaseReceivedArguments.borderStyle, .roundedRect, "Wrong getSpacingsUseCaseReceivedArguments.borderStyle")
        XCTAssertEqual(self.viewModel.leftSpacing, self.expectedSpacings.left, "Wrong leftSpacing")
        XCTAssertEqual(self.viewModel.contentSpacing, self.expectedSpacings.content, "Wrong contentSpacing")
        XCTAssertEqual(self.viewModel.rightSpacing, self.expectedSpacings.right, "Wrong rightSpacing")

        // THEN - Publishers
        XCTAssertEqual(self.publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(self.publishers.borderColor.sinkCount, 1, "$borderColorIndicatorColor should have been called once")
        XCTAssertEqual(self.publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(self.publishers.placeholderColor.sinkCount, 1, "$placeholderColor should have been called once")

        XCTAssertEqual(self.publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(self.publishers.borderRadius.sinkCount, 1, "$borderRadius should have been called once")

        XCTAssertEqual(self.publishers.leftSpacing.sinkCount, 1, "$leftSpacing should have been called once")
        XCTAssertEqual(self.publishers.contentSpacing.sinkCount, 1, "$contentSpacing should have been called once")
        XCTAssertEqual(self.publishers.rightSpacing.sinkCount, 1, "$rightSpacing should have been called once")

        XCTAssertEqual(self.publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertEqual(self.publishers.font.sinkCount, 1, "$font should have been called once")
    }

    // MARK: Theme
    func test_theme_didSet() throws {
        // GIVEN - Inits from setUp()
        let newTheme = ThemeGeneratedMock()
        newTheme.typography = TypographyGeneratedMock.mocked()
        newTheme.dims = DimsGeneratedMock.mocked()

        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        let newExpectedColors = TextFieldColors.mocked(
            text: .red(),
            placeholder: .blue(),
            border: .green(),
            background: .red()
        )
        self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = newExpectedColors

        let newExpectedBorderLayout = TextInputBorderLayout.mocked(radius: 20.0, width: 100.0)
        self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReturnValue = newExpectedBorderLayout

        let newExpectedSpacings = TextInputSpacings.mocked(left: 10, content: 20, right: 30)
        self.getSpacingsUseCase.executeWithThemeAndBorderStyleReturnValue = newExpectedSpacings

        // WHEN
        self.viewModel.theme = newTheme

        // THEN - Theme
        XCTAssertIdentical(self.viewModel.theme as? ThemeGeneratedMock, newTheme, "Wrong theme")

        // THEN - Colors
        XCTAssertEqual(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCallsCount, 1, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should have been called once")
        let getColorsReceivedArguments = try XCTUnwrap(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReceivedArguments, "Couldn't unwrap getColorsReceivedArguments")
        XCTAssertIdentical(getColorsReceivedArguments.theme as? ThemeGeneratedMock, newTheme, "Wrong getColorsReceivedArguments.theme")
        XCTAssertTrue(self.viewModel.textColor.equals(newExpectedColors.text), "Wrong textColor")
        XCTAssertTrue(self.viewModel.placeholderColor.equals(newExpectedColors.placeholder), "Wrong placeholderColor")
        XCTAssertTrue(self.viewModel.borderColor.equals(newExpectedColors.border), "Wrong borderColor")
        XCTAssertTrue(self.viewModel.backgroundColor.equals(newExpectedColors.background), "Wrong backgroundColor")

        // THEN - Border Layout
        XCTAssertEqual(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCallsCount, 1, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should have been called once")
        let getBorderLayoutReceivedArguments = try XCTUnwrap(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReceivedArguments, "Couldn't unwrap getBorderLayoutReceivedArguments")
        XCTAssertIdentical(getBorderLayoutReceivedArguments.theme as? ThemeGeneratedMock, newTheme, "Wrong getBorderLayoutReceivedArguments.theme")
        XCTAssertEqual(self.viewModel.borderWidth, newExpectedBorderLayout.width, "Wrong borderWidth")
        XCTAssertEqual(self.viewModel.borderRadius, newExpectedBorderLayout.radius, "Wrong borderRadius")

        // THEN - Spacings
        XCTAssertEqual(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCallsCount, 1, "getSpacingsUseCase.executeWithThemeAndBorderStyle should have been called once")
        let getSpacingsUseCaseReceivedArguments = try XCTUnwrap(self.getSpacingsUseCase.executeWithThemeAndBorderStyleReceivedArguments, "Couldn't unwrap getSpacingsUseCaseReceivedArguments")
        XCTAssertIdentical(getSpacingsUseCaseReceivedArguments.theme as? ThemeGeneratedMock, newTheme, "Wrong getSpacingsUseCaseReceivedArguments.theme")
        XCTAssertEqual(self.viewModel.leftSpacing, newExpectedSpacings.left, "Wrong leftSpacing")
        XCTAssertEqual(self.viewModel.contentSpacing, newExpectedSpacings.content, "Wrong contentSpacing")
        XCTAssertEqual(self.viewModel.rightSpacing, newExpectedSpacings.right, "Wrong rightSpacing")

        // THEN - Publishers
        XCTAssertEqual(self.publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(self.publishers.borderColor.sinkCount, 1, "$borderColorIndicatorColor should have been called once")
        XCTAssertEqual(self.publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(self.publishers.placeholderColor.sinkCount, 1, "$placeholderColor should have been called once")

        XCTAssertEqual(self.publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(self.publishers.borderRadius.sinkCount, 1, "$borderRadius should have been called once")

        XCTAssertEqual(self.publishers.leftSpacing.sinkCount, 1, "$leftSpacing should have been called once")
        XCTAssertEqual(self.publishers.contentSpacing.sinkCount, 1, "$contentSpacing should have been called once")
        XCTAssertEqual(self.publishers.rightSpacing.sinkCount, 1, "$rightSpacing should have been called once")

        XCTAssertEqual(self.publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertEqual(self.publishers.font.sinkCount, 1, "$font should have been called once")
    }

    // MARK: - Intent
    func test_intent_didSet_equal() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        // WHEN
        self.viewModel.intent = self.intent

        // THEN - Colors
        XCTAssertFalse(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCalled, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should not have been called")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertFalse(self.publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(self.publishers.borderColor.sinkCalled, "$borderColorIndicatorColor should not have been called")
        XCTAssertFalse(self.publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(self.publishers.placeholderColor.sinkCalled, "$placeholderColor should not have been called")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    func test_intent_didSet_notEqual() throws {
        // GIVEN - Inits from setUp()
        self.viewModel.intent = .alert
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        let newExpectedColors = TextFieldColors.mocked(
            text: .red(),
            placeholder: .blue(),
            border: .green(),
            background: .red()
        )
        self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = newExpectedColors

        // WHEN
        self.viewModel.intent = .neutral

        // THEN - Colors
        XCTAssertEqual(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCallsCount, 1, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should have been called once")
        let getColorsReceivedArguments = try XCTUnwrap(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReceivedArguments, "Couldn't unwrap getColorsReceivedArguments")
        XCTAssertEqual(getColorsReceivedArguments.intent, .neutral, "Wrong getColorsReceivedArguments.intent")
        XCTAssertTrue(self.viewModel.textColor.equals(newExpectedColors.text), "Wrong textColor")
        XCTAssertTrue(self.viewModel.placeholderColor.equals(newExpectedColors.placeholder), "Wrong placeholderColor")
        XCTAssertTrue(self.viewModel.borderColor.equals(newExpectedColors.border), "Wrong borderColor")
        XCTAssertTrue(self.viewModel.backgroundColor.equals(newExpectedColors.background), "Wrong backgroundColor")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertEqual(self.publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(self.publishers.borderColor.sinkCount, 1, "$borderColorIndicatorColor should have been called once")
        XCTAssertEqual(self.publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(self.publishers.placeholderColor.sinkCount, 1, "$placeholderColor should have been called once")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    // MARK: - Border Style
    func test_borderStyle_didSet_equal() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        // WHEN
        self.viewModel.borderStyle = self.borderStyle

        // THEN - Colors
        XCTAssertFalse(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCalled, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should not have been called")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertFalse(self.publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(self.publishers.borderColor.sinkCalled, "$borderColorIndicatorColor should not have been called")
        XCTAssertFalse(self.publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(self.publishers.placeholderColor.sinkCalled, "$placeholderColor should not have been called")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    func test_borderStyle_didSet_notEqual() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        let newExpectedBorderLayout = TextInputBorderLayout.mocked(radius: 20.0, width: 100.0)
        self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReturnValue = newExpectedBorderLayout

        let newExpectedSpacings = TextInputSpacings.mocked(left: 10, content: 20, right: 30)
        self.getSpacingsUseCase.executeWithThemeAndBorderStyleReturnValue = newExpectedSpacings

        // WHEN
        self.viewModel.borderStyle = .none

        // THEN - Colors
        XCTAssertFalse(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCalled, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should not have been called")

        // THEN - Border Layout
        XCTAssertEqual(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCallsCount, 1, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should have been called once")
        let getBorderLayoutReceivedArguments = try XCTUnwrap(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReceivedArguments, "Couldn't unwrap getBorderLayoutReceivedArguments")
        XCTAssertEqual(getBorderLayoutReceivedArguments.borderStyle, .none, "Wrong getBorderLayoutReceivedArguments.borderStyle")
        XCTAssertEqual(self.viewModel.borderWidth, newExpectedBorderLayout.width, "Wrong borderWidth")
        XCTAssertEqual(self.viewModel.borderRadius, newExpectedBorderLayout.radius, "Wrong borderRadius")

        // THEN - Spacings
        XCTAssertEqual(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCallsCount, 1, "getSpacingsUseCase.executeWithThemeAndBorderStyle should have been called once")
        let getSpacingsUseCaseReceivedArguments = try XCTUnwrap(self.getSpacingsUseCase.executeWithThemeAndBorderStyleReceivedArguments, "Couldn't unwrap getSpacingsUseCaseReceivedArguments")
        XCTAssertEqual(getSpacingsUseCaseReceivedArguments.borderStyle, .none, "Wrong getSpacingsUseCaseReceivedArguments.borderStyle")
        XCTAssertEqual(self.viewModel.leftSpacing, newExpectedSpacings.left, "Wrong leftSpacing")
        XCTAssertEqual(self.viewModel.contentSpacing, newExpectedSpacings.content, "Wrong contentSpacing")
        XCTAssertEqual(self.viewModel.rightSpacing, newExpectedSpacings.right, "Wrong rightSpacing")

        // THEN - Publishers
        XCTAssertFalse(self.publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(self.publishers.borderColor.sinkCalled, "$borderColorIndicatorColor should not have been called")
        XCTAssertFalse(self.publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(self.publishers.placeholderColor.sinkCalled, "$placeholderColor should not have been called")

        XCTAssertEqual(self.publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(self.publishers.borderRadius.sinkCount, 1, "$borderRadius should have been called once")

        XCTAssertEqual(self.publishers.leftSpacing.sinkCount, 1, "$leftSpacing should have been called once")
        XCTAssertEqual(self.publishers.contentSpacing.sinkCount, 1, "$contentSpacing should have been called once")
        XCTAssertEqual(self.publishers.rightSpacing.sinkCount, 1, "$rightSpacing should have been called once")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    // MARK: - Is Focused
    func test_isFocused_didSet_equal() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        // WHEN
        self.viewModel.isFocused = false

        // THEN - Colors
        XCTAssertFalse(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCalled, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should not have been called")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertFalse(self.publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(self.publishers.borderColor.sinkCalled, "$borderColorIndicatorColor should not have been called")
        XCTAssertFalse(self.publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(self.publishers.placeholderColor.sinkCalled, "$placeholderColor should not have been called")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    func test_isFocused_didSet_notEqual() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        let newExpectedColors = TextFieldColors.mocked(
            text: .red(),
            placeholder: .blue(),
            border: .green(),
            background: .red()
        )
        self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = newExpectedColors

        let newExpectedBorderLayout = TextInputBorderLayout.mocked(radius: 20.0, width: 100.0)
        self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReturnValue = newExpectedBorderLayout

        // WHEN
        self.viewModel.isFocused = true

        // THEN - Colors
        XCTAssertEqual(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCallsCount, 1, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should have been called once")
        let getColorsReceivedArguments = try XCTUnwrap(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReceivedArguments, "Couldn't unwrap getColorsReceivedArguments")
        XCTAssertIdentical(getColorsReceivedArguments.theme as? ThemeGeneratedMock, self.theme, "Wrong getColorsReceivedArguments.theme")
        XCTAssertEqual(getColorsReceivedArguments.intent, self.intent, "Wrong getColorsReceivedArguments.intent")
        XCTAssertTrue(getColorsReceivedArguments.isFocused, "Wrong getColorsReceivedArguments.isFocused")
        XCTAssertTrue(self.viewModel.textColor.equals(newExpectedColors.text), "Wrong textColor")
        XCTAssertTrue(self.viewModel.placeholderColor.equals(newExpectedColors.placeholder), "Wrong placeholderColor")
        XCTAssertTrue(self.viewModel.borderColor.equals(newExpectedColors.border), "Wrong borderColor")
        XCTAssertTrue(self.viewModel.backgroundColor.equals(newExpectedColors.background), "Wrong backgroundColor")

        // THEN - Border Layout
        XCTAssertEqual(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCallsCount, 1, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should have been called once")
        let getBorderLayoutReceivedArguments = try XCTUnwrap(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedReceivedArguments, "Couldn't unwrap getBorderLayoutReceivedArguments")
        XCTAssertTrue(getBorderLayoutReceivedArguments.isFocused, "Wrong getBorderLayoutReceivedArguments.isFocused")
        XCTAssertEqual(self.viewModel.borderWidth, newExpectedBorderLayout.width, "Wrong borderWidth")
        XCTAssertEqual(self.viewModel.borderRadius, newExpectedBorderLayout.radius, "Wrong borderRadius")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertEqual(self.publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(self.publishers.borderColor.sinkCount, 1, "$borderColorIndicatorColor should have been called once")
        XCTAssertEqual(self.publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(self.publishers.placeholderColor.sinkCount, 1, "$placeholderColor should have been called once")

        XCTAssertEqual(self.publishers.borderWidth.sinkCount, 1, "$borderWidth should have been called once")
        XCTAssertEqual(self.publishers.borderRadius.sinkCount, 1, "$borderRadius should have been called once")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should have not been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should have not been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should have not been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    // MARK: - Is Enabled
    func test_isEnabled_didSet_equal() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        // WHEN
        self.viewModel.isEnabled = true

        // THEN - Colors
        XCTAssertFalse(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCalled, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should not have been called")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertFalse(self.publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(self.publishers.borderColor.sinkCalled, "$borderColorIndicatorColor should not have been called")
        XCTAssertFalse(self.publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(self.publishers.placeholderColor.sinkCalled, "$placeholderColor should not have been called")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    func test_isEnabled_didSet_notEqual() throws {
        // GIVEN - Inits from setUp()
        self.viewModel.isEnabled = false
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        let newExpectedColors = TextFieldColors.mocked(
            text: .red(),
            placeholder: .blue(),
            border: .green(),
            background: .red()
        )
        self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = newExpectedColors

        // WHEN
        self.viewModel.isEnabled = true

        // THEN - Colors
        XCTAssertEqual(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCallsCount, 1, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should have been called once")
        let getColorsReceivedArguments = try XCTUnwrap(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReceivedArguments, "Couldn't unwrap getColorsReceivedArguments")
        XCTAssertIdentical(getColorsReceivedArguments.theme as? ThemeGeneratedMock, self.theme, "Wrong getColorsReceivedArguments.theme")
        XCTAssertEqual(getColorsReceivedArguments.intent, self.intent, "Wrong getColorsReceivedArguments.intent")
        XCTAssertTrue(getColorsReceivedArguments.isEnabled, "Wrong getColorsReceivedArguments.isEnabledd")
        XCTAssertTrue(self.viewModel.textColor.equals(newExpectedColors.text), "Wrong textColor")
        XCTAssertTrue(self.viewModel.placeholderColor.equals(newExpectedColors.placeholder), "Wrong placeholderColor")
        XCTAssertTrue(self.viewModel.borderColor.equals(newExpectedColors.border), "Wrong borderColor")
        XCTAssertTrue(self.viewModel.backgroundColor.equals(newExpectedColors.background), "Wrong backgroundColor")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertEqual(self.publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(self.publishers.borderColor.sinkCount, 1, "$borderColorIndicatorColor should have been called once")
        XCTAssertEqual(self.publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(self.publishers.placeholderColor.sinkCount, 1, "$placeholderColor should have been called once")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should have not been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should have not been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should have not been called")

        XCTAssertEqual(self.publishers.dim.sinkCount, 1, "$dim should have been called once")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    // MARK: - Is  Read Only
    func test_isReadOnly_didSet_equal() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        // WHEN
        self.viewModel.isReadOnly = false

        // THEN - Colors
        XCTAssertFalse(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCalled, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should not have been called")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertFalse(self.publishers.textColor.sinkCalled, "$textColor should not have been called")
        XCTAssertFalse(self.publishers.borderColor.sinkCalled, "$borderColorIndicatorColor should not have been called")
        XCTAssertFalse(self.publishers.backgroundColor.sinkCalled, "$backgroundColor should not have been called")
        XCTAssertFalse(self.publishers.placeholderColor.sinkCalled, "$placeholderColor should not have been called")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    func test_isReadOnly_didSet_notEqual() throws {
        // GIVEN - Inits from setUp()
        self.resetUseCases() // Removes execute from init
        self.publishers.reset() // Removes publishes from init

        let newExpectedColors = TextFieldColors.mocked(
            text: .red(),
            placeholder: .blue(),
            border: .green(),
            background: .red()
        )
        self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReturnValue = newExpectedColors

        // WHEN
        self.viewModel.isReadOnly = true

        // THEN - Colors
        XCTAssertEqual(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyCallsCount, 1, "getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnly should have been called once")
        let getColorsReceivedArguments = try XCTUnwrap(self.getColorsUseCase.executeWithThemeAndIntentAndIsFocusedAndIsEnabledAndIsReadOnlyReceivedArguments, "Couldn't unwrap getColorsReceivedArguments")
        XCTAssertIdentical(getColorsReceivedArguments.theme as? ThemeGeneratedMock, self.theme, "Wrong getColorsReceivedArguments.theme")
        XCTAssertEqual(getColorsReceivedArguments.intent, self.intent, "Wrong getColorsReceivedArguments.intent")
        XCTAssertTrue(getColorsReceivedArguments.isReadOnly, "Wrong getColorsReceivedArguments.isReadOnly")
        XCTAssertTrue(self.viewModel.textColor.equals(newExpectedColors.text), "Wrong textColor")
        XCTAssertTrue(self.viewModel.placeholderColor.equals(newExpectedColors.placeholder), "Wrong placeholderColor")
        XCTAssertTrue(self.viewModel.borderColor.equals(newExpectedColors.border), "Wrong borderColor")
        XCTAssertTrue(self.viewModel.backgroundColor.equals(newExpectedColors.background), "Wrong backgroundColor")

        // THEN - Border Layout
        XCTAssertFalse(self.getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocusedCalled, "getBorderLayoutUseCase.executeWithThemeAndBorderStyleAndIsFocused should not have been called")

        // THEN - Spacings
        XCTAssertFalse(self.getSpacingsUseCase.executeWithThemeAndBorderStyleCalled, "getSpacingsUseCase.executeWithThemeAndBorderStyle should not have been called")

        // THEN - Publishers
        XCTAssertEqual(self.publishers.textColor.sinkCount, 1, "$textColor should have been called once")
        XCTAssertEqual(self.publishers.borderColor.sinkCount, 1, "$borderColorIndicatorColor should have been called once")
        XCTAssertEqual(self.publishers.backgroundColor.sinkCount, 1, "$backgroundColor should have been called once")
        XCTAssertEqual(self.publishers.placeholderColor.sinkCount, 1, "$placeholderColor should have been called once")

        XCTAssertFalse(self.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")

        XCTAssertFalse(self.publishers.leftSpacing.sinkCalled, "$leftSpacing should have not been called")
        XCTAssertFalse(self.publishers.contentSpacing.sinkCalled, "$contentSpacing should have not been called")
        XCTAssertFalse(self.publishers.rightSpacing.sinkCalled, "$rightSpacing should have not been called")

        XCTAssertFalse(self.publishers.dim.sinkCalled, "$dim should not have been called")
        XCTAssertFalse(self.publishers.font.sinkCalled, "$font should not have been called")
    }

    // MARK: - Utils
    func setupPublishers() {
        self.publishers = .init(
            textColor: PublisherMock(publisher: self.viewModel.$textColor),
            placeholderColor: PublisherMock(publisher: self.viewModel.$placeholderColor),
            borderColor: PublisherMock(publisher: self.viewModel.$borderColor),
            backgroundColor: PublisherMock(publisher: self.viewModel.$backgroundColor),
            borderRadius: PublisherMock(publisher: self.viewModel.$borderRadius),
            borderWidth: PublisherMock(publisher: self.viewModel.$borderWidth),
            leftSpacing: PublisherMock(publisher: self.viewModel.$leftSpacing),
            contentSpacing: PublisherMock(publisher: self.viewModel.$contentSpacing),
            rightSpacing: PublisherMock(publisher: self.viewModel.$rightSpacing),
            dim: PublisherMock(publisher: self.viewModel.$dim),
            font: PublisherMock(publisher: self.viewModel.$font)
        )
        self.publishers.load()
    }

    func resetUseCases() {
        self.getColorsUseCase.reset()
        self.getBorderLayoutUseCase.reset()
        self.getSpacingsUseCase.reset()
    }
}

final class TextFieldPublishers {
    var cancellables = Set<AnyCancellable>()

    var textColor: PublisherMock<Published<any ColorToken>.Publisher>
    var placeholderColor: PublisherMock<Published<any ColorToken>.Publisher>
    var borderColor: PublisherMock<Published<any ColorToken>.Publisher>
    var backgroundColor: PublisherMock<Published<any ColorToken>.Publisher>

    var borderRadius: PublisherMock<Published<CGFloat>.Publisher>
    var borderWidth: PublisherMock<Published<CGFloat>.Publisher>

    var leftSpacing: PublisherMock<Published<CGFloat>.Publisher>
    var contentSpacing: PublisherMock<Published<CGFloat>.Publisher>
    var rightSpacing: PublisherMock<Published<CGFloat>.Publisher>

    var dim: PublisherMock<Published<CGFloat>.Publisher>

    var font: PublisherMock<Published<any TypographyFontToken>.Publisher>

    init(
        textColor: PublisherMock<Published<any ColorToken>.Publisher>,
        placeholderColor: PublisherMock<Published<any ColorToken>.Publisher>,
        borderColor: PublisherMock<Published<any ColorToken>.Publisher>,
        backgroundColor: PublisherMock<Published<any ColorToken>.Publisher>,
        borderRadius: PublisherMock<Published<CGFloat>.Publisher>,
        borderWidth: PublisherMock<Published<CGFloat>.Publisher>,
        leftSpacing: PublisherMock<Published<CGFloat>.Publisher>,
        contentSpacing: PublisherMock<Published<CGFloat>.Publisher>,
        rightSpacing: PublisherMock<Published<CGFloat>.Publisher>,
        dim: PublisherMock<Published<CGFloat>.Publisher>,
        font: PublisherMock<Published<any TypographyFontToken>.Publisher>
    ) {
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
        self.borderRadius = borderRadius
        self.borderWidth = borderWidth
        self.leftSpacing = leftSpacing
        self.contentSpacing = contentSpacing
        self.rightSpacing = rightSpacing
        self.dim = dim
        self.font = font
    }

    func load() {
        self.cancellables = Set<AnyCancellable>()

        [self.textColor, self.placeholderColor, self.borderColor, self.backgroundColor].forEach {
            $0.loadTesting(on: &self.cancellables)
        }

        [self.borderWidth, self.borderRadius, self.leftSpacing, self.contentSpacing, self.rightSpacing, self.dim].forEach {
            $0.loadTesting(on: &self.cancellables)
        }

        self.font.loadTesting(on: &self.cancellables)
    }

    func reset() {
        [self.textColor, self.placeholderColor, self.borderColor, self.backgroundColor].forEach {
            $0.reset()
        }

        [self.borderWidth, self.borderRadius, self.leftSpacing, self.contentSpacing, self.rightSpacing, self.dim].forEach {
            $0.reset()
        }

        self.font.reset()
    }
}
