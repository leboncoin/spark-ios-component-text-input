//
//  TextFieldUIView.swift
//  SparkTextField
//
//  Created by louis.borlee on 05/02/2024.
//  Copyright © 2024 Leboncoin. All rights reserved.
//

import UIKit
import Combine
@_spi(SI_SPI) import SparkCommon
import SparkTheming

/// Spark TextField, subclasses UITextField
public final class TextFieldUIView: UITextField {

    // MARK: - Properties

    private let viewModel: TextInputViewModel
    private var cancellables = Set<AnyCancellable>()

    @ScaledUIMetric private var height: CGFloat = TextInputConstants.height

    @ScaledUIMetric private var scaleCornerRadius: CGFloat = 0
    @ScaledUIMetric private var scaleBorderWidth: CGFloat = 0

    private let defaultClearButtonRightSpacing = 5.0

    public override var placeholder: String? {
        didSet {
            self.setPlaceholder(self.placeholder, foregroundColor: self.viewModel.placeholderColor, font: self.viewModel.font)
        }
    }

    public override var isEnabled: Bool {
        didSet {
            self.viewModel.isEnabled = self.isEnabled
        }
    }

    public override var isUserInteractionEnabled: Bool {
        didSet {
            self.viewModel.isReadOnly = !self.isUserInteractionEnabled
        }
    }

    public override var borderStyle: UITextField.BorderStyle {
        @available(*, unavailable)
        set {}
        get { return .init(self.viewModel.borderStyle) }
    }

    /// The textfield's current theme.
    public var theme: Theme {
        get {
            return self.viewModel.theme
        }
        set {
            self.viewModel.theme = newValue
        }
    }
    /// The textfield's current intent.
    public var intent: TextFieldIntent {
        get {
            return self.viewModel.intent
        }
        set {
            self.viewModel.intent = newValue
        }
    }

    // MARK: - Initialization

    internal init(viewModel: TextInputViewModel) {
        self.viewModel = viewModel
        super.init(frame: .init(origin: .zero, size: .init(width: 0, height: TextInputConstants.height)))
        self.adjustsFontForContentSizeCategory = true
        self.adjustsFontSizeToFitWidth = false
        self.setupView()
    }

    internal convenience init(
        theme: Theme,
        intent: TextFieldIntent,
        borderStyle: TextInputBorderStyle
    ) {
        self.init(
            viewModel: .init(
                theme: theme,
                intent: intent,
                borderStyle: borderStyle
            )
        )
    }

    /// TextFieldUIView initializer
    /// - Parameters:
    ///   - theme: The textfield's current theme
    ///   - intent: The textfield's current intent
    public convenience init(
        theme: Theme,
        intent: TextFieldIntent
    ) {
        self.init(
            viewModel: .init(
                theme: theme,
                intent: intent,
                borderStyle: .roundedRect
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        self.subscribeToViewModel()
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.accessibilityIdentifier = TextFieldAccessibilityIdentifier.view
    }

    private func subscribeToViewModel() {
        self.viewModel.$textColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] textColor in
            guard let self else { return }
            self.textColor = textColor.uiColor
            self.tintColor = textColor.uiColor
        }

        self.viewModel.$backgroundColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] backgroundColor in
            guard let self else { return }
            self.backgroundColor = backgroundColor.uiColor
        }

        self.viewModel.$borderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] borderColor in
            guard let self else { return }
            self.setBorderColor(from: borderColor)
        }

        self.viewModel.$placeholderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] placeholderColor in
            guard let self else { return }
            self.setPlaceholder(self.placeholder, foregroundColor: placeholderColor, font: self.viewModel.font)
        }

        self.viewModel.$borderWidth.subscribe(in: &self.cancellables) { [weak self] borderWidth in
            guard let self else { return }

            self.scaleBorderWidth = borderWidth
            self._scaleBorderWidth.update(traitCollection: self.traitCollection)

            self.setBorderWidth(self.scaleBorderWidth)
        }

        self.viewModel.$borderRadius.subscribe(in: &self.cancellables) { [weak self] borderRadius in
            guard let self else { return }

            self.scaleCornerRadius = borderRadius
            self._scaleCornerRadius.update(traitCollection: self.traitCollection)

            self.setCornerRadius(self.scaleCornerRadius)
        }

        self.viewModel.$leftSpacing.subscribe(in: &self.cancellables) { [weak self] leftSpacing in
            guard let self else { return }
            self.setNeedsLayout()
        }

        self.viewModel.$rightSpacing.subscribe(in: &self.cancellables) { [weak self] rightSpacing in
            guard let self else { return }
            self.setNeedsLayout()
        }

        self.viewModel.$contentSpacing.subscribe(in: &self.cancellables) { [weak self] contentSpacing in
            guard let self else { return }
            self.setNeedsLayout()
        }

        self.viewModel.$dim.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] dim in
            guard let self else { return }
            self.alpha = dim
        }

        self.viewModel.$font.subscribe(in: &self.cancellables) { [weak self] font in
            guard let self else { return }
            self.font = font.uiFont
            self.setPlaceholder(self.placeholder, foregroundColor: self.viewModel.placeholderColor, font: font)
        }
    }

    // MARK: - Setter

    private func setAttributedPlaceholder(string: String, foregroundColor: UIColor, font: UIFont) {
        self.attributedPlaceholder = NSAttributedString(
            string: string,
            attributes: [
                NSAttributedString.Key.foregroundColor: foregroundColor,
                NSAttributedString.Key.font: font
            ]
        )
    }

    private func setPlaceholder(_ placeholder: String?, foregroundColor: any ColorToken, font: TypographyFontToken) {
        if let placeholder {
            self.setAttributedPlaceholder(string: placeholder, foregroundColor: foregroundColor.uiColor, font: font.uiFont)
        } else {
            self.attributedPlaceholder = nil
        }
    }

    private func setInsets(forBounds bounds: CGRect) -> CGRect {
        var totalInsets = UIEdgeInsets(
            top: 0,
            left: self.viewModel.leftSpacing,
            bottom: 0,
            right: self.viewModel.rightSpacing
        )
        let contentSpacing = self.viewModel.contentSpacing
        if let leftView,
           leftView.isDescendant(of: self) {
            totalInsets.left += leftView.bounds.size.width + contentSpacing
        }
        if let rightView,
           rightView.isDescendant(of: self) {
            totalInsets.right += rightView.bounds.size.width + contentSpacing
        }
        if let clearButton = self.value(forKeyPath: "_clearButton") as? UIButton,
           clearButton.isDescendant(of: self) {
            totalInsets.right += clearButton.bounds.size.width + contentSpacing
        }
        return bounds.inset(by: totalInsets)
    }

    // MARK: - Override Methods

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.setInsets(forBounds: bounds)
    }

    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return self.setInsets(forBounds: bounds)
    }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.setInsets(forBounds: bounds)
    }

    private func getClearButtonXOffset() -> CGFloat {
        return -self.viewModel.rightSpacing + self.defaultClearButtonRightSpacing
    }

    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: bounds)
            .offsetBy(dx: self.getClearButtonXOffset(), dy: 0)
    }

    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: bounds)
            .offsetBy(dx: self.viewModel.leftSpacing, dy: 0)
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds)
            .offsetBy(dx: -self.viewModel.rightSpacing, dy: 0)
    }

    // MARK: - Responder

    public override func becomeFirstResponder() -> Bool {
        let bool = super.becomeFirstResponder()
        self.viewModel.isFocused = bool
        return bool
    }

    public override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.viewModel.isFocused = false
        return true
    }

    // MARK: - Trait Collection

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setBorderColor(from: self.viewModel.borderColor)
        }

        guard previousTraitCollection?.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory else { return }

        self._height.update(traitCollection: self.traitCollection)

        self._scaleCornerRadius.update(traitCollection: self.traitCollection)
        self._scaleBorderWidth.update(traitCollection: self.traitCollection)

        self.setCornerRadius(self.scaleCornerRadius)
        self.setBorderWidth(self.scaleBorderWidth)

        self.invalidateIntrinsicContentSize()
    }

    // MARK: - Instrinsic Content Size

    public override var intrinsicContentSize: CGSize {
        return .init(
            width: super.intrinsicContentSize.width,
            height: self.height
        )
    }
}
