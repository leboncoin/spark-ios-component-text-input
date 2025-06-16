//
//  TextFieldSecureModeEnvironmentValues.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 04/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var textFieldSecureMode: Bool = false
}

public extension View {

    /// Set the **secure mode**  on the``SparkTextField``.
    ///
    /// If the secure mode is *true*, the text will be replaced by dots. The default value for this property is *false*.
    @ViewBuilder
    func textFieldSecureMode(_ isSecureMode: Bool) -> some View {
        self.environment(\.textFieldSecureMode, isSecureMode)
    }
}
