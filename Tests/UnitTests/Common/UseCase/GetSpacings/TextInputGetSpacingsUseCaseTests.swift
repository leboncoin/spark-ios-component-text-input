//
//  TextInputGetSpacingsUseCaseTests.swift
//  SparkTextFieldUnitTests
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

    func test_execute() {
        // GIVEN
        let useCase = TextInputGetSpacingsUseCase()

        // WHEN
        let spacings = useCase.execute(
            theme: self.themeMock
        )

        // THEN
        XCTAssertEqual(spacings.left, self.themeMock.layout.spacing.large)
        XCTAssertEqual(spacings.content, self.themeMock.layout.spacing.medium)
        XCTAssertEqual(spacings.right, self.themeMock.layout.spacing.large)
    }
}
