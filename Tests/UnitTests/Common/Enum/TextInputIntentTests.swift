//
//  TextInputIntentTests.swift
//  SparkTextInputUnitTests
//
//  Created by Robin Lemaire on 20/10/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import XCTest
@testable import SparkTextInput

final class TextInputIntentTests: XCTestCase {

    // MARK: - Tests

    func test_default() {
        // GIVEN / WHEN / THEN
        XCTAssertEqual(TextInputIntent.default, .neutral)
    }
}
