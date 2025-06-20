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
protocol TextInputGetSpacingsUseCaseable {
    func execute(
        theme: Theme,
        borderStyle: TextInputBorderStyle
    ) -> TextInputSpacings

    func execute(theme: Theme) -> TextInputSpacings
}

final class TextInputGetSpacingsUseCase: TextInputGetSpacingsUseCaseable {

    // MARK: - Methods

    func execute(theme: Theme, borderStyle: TextInputBorderStyle) -> TextInputSpacings {
        return switch borderStyle {
        case .none:
            .init(
                horizontal: theme.layout.spacing.none,
                content: theme.layout.spacing.medium
            )
        case .roundedRect:
            self.execute(theme: theme)
        }
    }

    func execute(theme: Theme) -> TextInputSpacings {
        return .init(
            horizontal: theme.layout.spacing.large,
            content: theme.layout.spacing.medium
        )
    }
}
