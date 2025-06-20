//
//  TextFieldAddonConfiguration.swift
//  SparkTextInput
//
//  Created by robin.lemaire on 18/06/2025.
//  Copyright © 2025 Leboncoin. All rights reserved.
//

import Foundation

/// The view configuration for the TextField Addon for **SwiftUI**.
public struct TextFieldAddonConfiguration: Equatable {

    // MARK: - Properties

    let hasPadding: Bool
    let hasSeparator: Bool
    let layoutPriority: CGFloat

    // MARK: - Initialization

    /// Init the addon configuration.
    /// - Parameters:
    ///   - hasPadding: Add a padding or not on the addon. Default is **false**.
    ///   - hasSeparator: Add a separator on the addon. Default is **false**.
    ///   - layoutPriority: The layout priority of the addon. Default is **1**.
    public init(hasPadding: Bool = false, hasSeparator: Bool = false, layoutPriority: CGFloat = 1.0) {
        self.hasPadding = hasPadding
        self.hasSeparator = hasSeparator
        self.layoutPriority = layoutPriority
    }
}
