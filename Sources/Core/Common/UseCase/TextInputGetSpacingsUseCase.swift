//
//  TextInputGetSpacingsUseCase.swift
//  SparkTextField
//
//  Created by louis.borlee on 25/09/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import Foundation
import SparkTheming

// sourcery: AutoMockable
protocol TextInputGetSpacingsUseCasable {
    func execute(theme: Theme, borderStyle: TextInputBorderStyle) -> TextInputSpacings
}

final class TextInputGetSpacingsUseCase: TextInputGetSpacingsUseCasable {

    // MARK: - Methods

    func execute(theme: Theme, borderStyle: TextInputBorderStyle) -> TextInputSpacings {
        switch borderStyle {
        case .none:
            return .init(
                left: theme.layout.spacing.none,
                content: theme.layout.spacing.medium,
                right: theme.layout.spacing.none
            )
        case .roundedRect:
            return .init(
                left: theme.layout.spacing.large,
                content: theme.layout.spacing.medium,
                right: theme.layout.spacing.large
            )
        }
    }
}
