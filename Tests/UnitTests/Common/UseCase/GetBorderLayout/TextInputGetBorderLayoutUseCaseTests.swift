//
//  TextInputGetBorderLayoutUseCaseTests.swift
//  SparkTextFieldUnitTests
//
//  Created by louis.borlee on 01/02/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import XCTest
@testable import SparkTextInput
@_spi(SI_SPI) import SparkThemingTesting

final class TextInputGetBorderLayoutUseCaseTests: XCTestCase {

    // MARK: - Properties

    private let theme = ThemeGeneratedMock.mocked()

    // MARK: - Tests

    func test_isFocused() {
        // GIVEN
        let useCase = TextInputGetBorderLayoutUseCase()
        let isFocused = true

        // WHEN
        let borderLayout = useCase.execute(
            theme: self.theme,
            isFocused: isFocused
        )

        // THEN
        XCTAssertEqual(borderLayout.radius, self.theme.border.radius.large, "Wrong radius")
        XCTAssertEqual(borderLayout.width, self.theme.border.width.medium, "Wrong width")
    }

    func test_isNotFocused() {
        // GIVEN
        let useCase = TextInputGetBorderLayoutUseCase()
        let isFocused = false

        // WHEN
        let borderLayout = useCase.execute(
            theme: self.theme,
            isFocused: isFocused
        )

        // THEN
        XCTAssertEqual(borderLayout.radius, self.theme.border.radius.large, "Wrong radius")
        XCTAssertEqual(borderLayout.width, self.theme.border.width.small, "Wrong width")
    }
}
