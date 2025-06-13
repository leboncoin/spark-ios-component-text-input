//
//  TextFieldGetContentPaddingUseCase.swift
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
protocol TextFieldGetContentPaddingUseCaseable {
    func execute(spacings: TextInputSpacings, isClearButton: Bool) -> EdgeInsets
}

final class TextFieldGetContentPaddingUseCase: TextFieldGetContentPaddingUseCaseable {

    // MARK: - Methods

    func execute(spacings: TextInputSpacings, isClearButton: Bool) -> EdgeInsets {
        .init(
            top: .zero,
            leading: spacings.left,
            bottom: .zero,
            trailing: isClearButton ? .zero : spacings.right
        )
    }
}
