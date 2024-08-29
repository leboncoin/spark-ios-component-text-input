//
//  TextInputViewModelTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import XCTest
import Combine
import UIKit
import SwiftUI
@testable import SparkTextInput
@_spi(SI_SPI) @testable import SparkTextInputTesting
@_spi(SI_SPI) import SparkCommon
@_spi(SI_SPI) import SparkCommonTesting
import SparkTheming
@_spi(SI_SPI) import SparkThemingTesting

final class TextInputViewModelForAddonsTests: XCTestCase {

    // MARK: - Properties

    private let superTests: TextInputViewModelTests = .init()
    private var viewModel: TextInputViewModelForAddons!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        self.superTests.setUp()

        self.viewModel = .init(
            theme: self.superTests.theme,
            intent: self.superTests.intent,
            getColorsUseCase: self.superTests.getColorsUseCase,
            getBorderLayoutUseCase: self.superTests.getBorderLayoutUseCase,
            getSpacingsUseCase: self.superTests.getSpacingsUseCase
        )
    }

    // MARK: - Tests

    func test_backgroundColor() {
        self.superTests.publishers.reset()
        self.superTests.resetUseCases()

        XCTAssertTrue(self.viewModel.backgroundColor.equals(ColorTokenDefault.clear), "Wrong viewModel.backgroundColor before set")

        let newColor = ColorTokenGeneratedMock(uiColor: .brown)
        self.viewModel.backgroundColor = newColor

        XCTAssertTrue(self.viewModel.backgroundColor.equals(ColorTokenDefault.clear), "Wrong viewModel.backgroundColor after set")
        XCTAssertTrue(self.viewModel.addonsBackgroundColor.equals(newColor), "Wrong delegate.backgroundColor")

        XCTAssertFalse(self.superTests.publishers.backgroundColor.sinkCalled, "backgroundColor should not have sinked")
    }

    func test_dim() {
        self.superTests.publishers.reset()
        self.superTests.resetUseCases()

        XCTAssertEqual(self.viewModel.dim, 1.0, "Wrong viewModel.dim before set")

        let newDim = 0.2
        self.viewModel.dim = newDim

        XCTAssertEqual(self.viewModel.dim, 1.0, "Wrong viewModel.dim after set")
        XCTAssertEqual(self.viewModel.addonsDim, newDim, "Wrong delegate.dim")

        XCTAssertFalse(self.superTests.publishers.dim.sinkCalled, "dim should not have sinked")
    }

    func test_setBorderLayout() throws {
        self.superTests.publishers.reset()
        self.superTests.resetUseCases()

        let newExpectedBorderLayout: TextFieldBorderLayout = .mocked(radius: 40, width: 40)
        self.superTests.getBorderLayoutUseCase.executeWithThemeAndIsFocusedReturnValue = newExpectedBorderLayout

        // WHEN
        self.viewModel.setBorderLayout()

        // THEN
        XCTAssertEqual(self.viewModel.addonsBorderWidth, newExpectedBorderLayout.width, "Wrong delegate.boderWidth")
        XCTAssertEqual(self.viewModel.addonsBorderRadius, newExpectedBorderLayout.radius, "Wrong delegate.boderRadius")
        // Border with & Radius shouldn't change, the delegate takes charge
        XCTAssertEqual(self.viewModel.borderWidth, self.superTests.expectedBorderLayout.width, "Wrong viewModel.borderRadius")
        XCTAssertEqual(self.viewModel.borderRadius, self.superTests.expectedBorderLayout.radius, "Wrong viewModel.borderWidth")

        XCTAssertEqual(self.superTests.getBorderLayoutUseCase.executeWithThemeAndIsFocusedCallsCount, 1, "getBorderLayoutUseCase.executeWithThemeAndIsFocused should have been called once")
        let getBorderLayoutReceivedArguments = try XCTUnwrap(self.superTests.getBorderLayoutUseCase.executeWithThemeAndIsFocusedReceivedArguments, "Couldn't unwrap getBorderLayoutReceivedArguments")
        XCTAssertIdentical(getBorderLayoutReceivedArguments.theme as? ThemeGeneratedMock, self.superTests.theme, "Wrong getBorderLayoutReceivedArguments.theme")
        XCTAssertFalse(getBorderLayoutReceivedArguments.isFocused, "Wrong getBorderLayoutReceivedArguments.isFocused")

        XCTAssertFalse(self.superTests.publishers.borderWidth.sinkCalled, "$borderWidth should not have been called")
        XCTAssertFalse(self.superTests.publishers.borderRadius.sinkCalled, "$borderRadius should not have been called")
    }

    func test_setSpacings() throws {
        self.superTests.publishers.reset()
        self.superTests.resetUseCases()

        let newExpectedSpacings = TextFieldSpacings.mocked(left: 2, content: 4, right: 3)
        self.superTests.getSpacingsUseCase.executeWithThemeReturnValue = newExpectedSpacings

        // WHEN
        self.viewModel.setSpacings()

        // THEN
        XCTAssertEqual(self.viewModel.addonsLeftSpacing, newExpectedSpacings.left)
        XCTAssertEqual(self.viewModel.addonsContentSpacing, newExpectedSpacings.content)
        XCTAssertEqual(self.viewModel.addonsRightSpacing, newExpectedSpacings.right)

        // Spacings shouldn't change, the delegate takes charge
        XCTAssertEqual(self.viewModel.leftSpacing, self.superTests.expectedSpacings.left)
        XCTAssertEqual(self.viewModel.contentSpacing, self.superTests.expectedSpacings.content)
        XCTAssertEqual(self.viewModel.rightSpacing, self.superTests.expectedSpacings.right)

        XCTAssertEqual(self.superTests.getSpacingsUseCase.executeWithThemeCallsCount, 1, "getSpacingsUseCase.executeWithTheme should have been called once")
        XCTAssertIdentical(self.superTests.getSpacingsUseCase.executeWithThemeReceivedTheme as? ThemeGeneratedMock, self.superTests.theme, "Wrong getSpacingsUseCase theme")

        XCTAssertFalse(self.superTests.publishers.leftSpacing.sinkCalled, "$leftSpacing should not have been called")
        XCTAssertFalse(self.superTests.publishers.contentSpacing.sinkCalled, "$contentSpacing should not have been called")
        XCTAssertFalse(self.superTests.publishers.rightSpacing.sinkCalled, "$rightSpacing should not have been called")
    }
}
