//
//  TextInputIntent.swift
//  Spark
//
//  Created by Quentin.richard on 21/09/2023.
//  Copyright © 2023 Leboncoin. All rights reserved.
//

import Foundation

/// The intent of the input (textField & textEditor).
public enum TextInputIntent: CaseIterable {
    case error
    case alert
    case neutral
    case success
}
