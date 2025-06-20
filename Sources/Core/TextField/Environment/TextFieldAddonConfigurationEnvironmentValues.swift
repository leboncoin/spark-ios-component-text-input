//
//  TextFieldAddonConfigurationEnvironmentValues.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 04/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var textFieldLeftAddonConfiguration: TextFieldAddonConfiguration = .init()
    @Entry var textFieldRightAddonConfiguration: TextFieldAddonConfiguration = .init()
}

public extension View {

    /// Add a **configuration** on **left addon**  on the``SparkTextField``.
    /// 
    /// Check the ``TextFieldAddonConfiguration`` **init** to see the default values.
    func sparkTextFieldLeftAddonConfiguration(_ configuration: TextFieldAddonConfiguration) -> some View {
        self.environment(\.textFieldLeftAddonConfiguration, configuration)
    }

    /// Add a **configuration** on **right addon**  on the``SparkTextField``.
    ///
    /// Check the ``TextFieldAddonConfiguration`` **init** to see the default values.
    func sparkTextFieldRightAddonConfiguration(_ configuration: TextFieldAddonConfiguration) -> some View {
        self.environment(\.textFieldRightAddonConfiguration, configuration)
    }
}
