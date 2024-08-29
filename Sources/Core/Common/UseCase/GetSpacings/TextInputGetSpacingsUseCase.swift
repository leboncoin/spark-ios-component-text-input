//
//  TextInputGetSpacingsUseCase.swift
//  SparkTextField
//
//  Created by louis.borlee on 25/09/2023.
//  Copyright © 2023 Adevinta. All rights reserved.
//

import Foundation
import SparkTheming

// sourcery: AutoMockable
protocol TextInputGetSpacingsUseCasable {
    func execute(theme: Theme) -> TextFieldSpacings
}

final class TextInputGetSpacingsUseCase: TextInputGetSpacingsUseCasable {

    // MARK: - Methods
    
    func execute(theme: Theme) -> TextFieldSpacings {
        return .init(
            left: theme.layout.spacing.large,
            content: theme.layout.spacing.medium,
            right: theme.layout.spacing.large
        )
    }
}
