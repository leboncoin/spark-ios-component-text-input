//
//  TextEditorViewModel.swift
//  SparkEditor
//
//  Created by robin.lemaire on 05/09/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import Foundation
import SparkTheming

// sourcery: AutoPublisherTest, AutoViewModelStub
final class TextEditorViewModel: TextInputViewModel {

    // MARK: - Published Properties

    @Published private(set) var isPlaceholder: Bool = false
    @Published private(set) var shouldUpdateVerticalSpacing: Int = 0

    // MARK: - Private Properties

    private let getVerticalSpacingUseCase: TextEditorGetVerticalSpacingUseCaseable

    // MARK: - Initialization

    init(
        theme: Theme,
        intent: TextEditorIntent,
        getVerticalSpacingUseCase: TextEditorGetVerticalSpacingUseCaseable = TextEditorGetVerticalSpacingUseCase()
    ) {
        self.getVerticalSpacingUseCase = getVerticalSpacingUseCase

        super.init(theme: theme, intent: intent)
    }

    // MARK: - Update

    func contentChanged(with text: String) {
        self.isPlaceholder = text.isEmpty
    }

    func traitCollectionChanged() {
        self.shouldUpdateVerticalSpacing += 1
    }

    // MARK: - Getter

    func getVerticalSpacing(from height: CGFloat) -> CGFloat {
        self.getVerticalSpacingUseCase.execute(
            height: height,
            font: self.font
        )
    }

    // MARK: - Setter

    override func setFont() {
        super.setFont()

        self.shouldUpdateVerticalSpacing += 1
    }
}
