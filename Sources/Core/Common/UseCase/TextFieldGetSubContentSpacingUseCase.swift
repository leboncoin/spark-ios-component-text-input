//
//  TextFieldGetSubContentSpacingUseCase.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 11/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import Foundation
import SparkTheming
import SwiftUI

// TODO: test

// sourcery: AutoMockable
protocol TextFieldGetSubContentSpacingUseCaseable {
    func execute(spacings: TextInputSpacings, isClearButton: Bool) -> CGFloat
}

final class TextFieldGetSubContentSpacingUseCase: TextFieldGetSubContentSpacingUseCaseable {

    // MARK: - Methods

    func execute(spacings: TextInputSpacings, isClearButton: Bool) -> CGFloat {
        isClearButton ? .zero : spacings.content
    }
}
