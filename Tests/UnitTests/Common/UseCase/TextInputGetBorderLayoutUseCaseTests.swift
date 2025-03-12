//
//  TextInputGetBorderLayoutUseCaseTests.swift
//  SparkTextInputUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import XCTest
@testable import SparkTextInput
@_spi(SI_SPI) import SparkThemingTesting

final class TextInputGetBorderLayoutUseCaseTests: XCTestCase {

    // MARK: - Properties

    private let theme = ThemeGeneratedMock.mocked()

    // MARK: - Tests

    func test_roundedRect_isFocused() {
        // GIVEN
        let useCase = TextInputGetBorderLayoutUseCase()
        let borderStyle = TextInputBorderStyle.roundedRect
        let isFocused = true

        // WHEN
        let borderLayout = useCase.execute(
            theme: self.theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )

        // THEN
        XCTAssertEqual(borderLayout.radius, self.theme.border.radius.large, "Wrong radius")
        XCTAssertEqual(borderLayout.width, self.theme.border.width.medium, "Wrong width")
    }

    func test_roundedRect_isNotFocused() {
        // GIVEN
        let useCase = TextInputGetBorderLayoutUseCase()
        let borderStyle = TextInputBorderStyle.roundedRect
        let isFocused = false

        // WHEN
        let borderLayout = useCase.execute(
            theme: self.theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )

        // THEN
        XCTAssertEqual(borderLayout.radius, self.theme.border.radius.large, "Wrong radius")
        XCTAssertEqual(borderLayout.width, self.theme.border.width.small, "Wrong width")
    }

    func test_none_isFocused() {
        // GIVEN
        let useCase = TextInputGetBorderLayoutUseCase()
        let borderStyle = TextInputBorderStyle.none
        let isFocused = true

        // WHEN
        let borderLayout = useCase.execute(
            theme: self.theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )

        // THEN
        XCTAssertEqual(borderLayout.radius, self.theme.border.radius.none, "Wrong radius")
        XCTAssertEqual(borderLayout.width, self.theme.border.width.none, "Wrong width")
    }

    func test_none_isNotFocused() {
        // GIVEN
        let useCase = TextInputGetBorderLayoutUseCase()
        let borderStyle = TextInputBorderStyle.none
        let isFocused = false

        // WHEN
        let borderLayout = useCase.execute(
            theme: self.theme,
            borderStyle: borderStyle,
            isFocused: isFocused
        )

        // THEN
        XCTAssertEqual(borderLayout.radius, self.theme.border.radius.none, "Wrong radius")
        XCTAssertEqual(borderLayout.width, self.theme.border.width.none, "Wrong width")
    }
}
