//
//  TextInputGetSpacingsUseCaseTests.swift
//  SparkTextInputUnitTests
//
//  Created by Jacklyn Situmorang on 17.10.23.
//  Copyright © 2023 Adevinta. All rights reserved.
//

import XCTest

@testable import SparkTextInput
@_spi(SI_SPI) import SparkThemingTesting

final class TextInputGetSpacingsUseCaseTests: XCTestCase {

    // MARK: - Properties

    private let themeMock = ThemeGeneratedMock.mocked()

    // MARK: - Tests

    func test_execute_for_none() {
        self.testExecute(
            givenBorderStyle: .none,
            expectedSpacings: .init(
                left: self.themeMock.layout.spacing.none,
                content: self.themeMock.layout.spacing.medium,
                right: self.themeMock.layout.spacing.none
            )
        )
    }

    func text_execute_for_roundedRect() {
        self.testExecute(
            givenBorderStyle: .roundedRect,
            expectedSpacings: .init(
                left: self.themeMock.layout.spacing.large,
                content: self.themeMock.layout.spacing.medium,
                right: self.themeMock.layout.spacing.large
            )
        )
    }
}

private extension TextInputGetSpacingsUseCaseTests {
    func testExecute(
        givenBorderStyle: TextInputBorderStyle,
        expectedSpacings: TextInputSpacings
    ) {
        // GIVEN
        let useCase = TextInputGetSpacingsUseCase()

        // WHEN
        let spacings = useCase.execute(
            theme: self.themeMock,
            borderStyle: givenBorderStyle
        )

        // THEN
        XCTAssertEqual(spacings.content, expectedSpacings.content)
        XCTAssertEqual(spacings.left, expectedSpacings.left)
        XCTAssertEqual(spacings.right, expectedSpacings.right)
    }
}
