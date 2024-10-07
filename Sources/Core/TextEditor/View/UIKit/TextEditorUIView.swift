//
//  TextEditorUIView.swift
//  SparkEditor
//
//  Created by robin.lemaire on 05/09/2024.
//  Copyright © 2024 Adevinta. All rights reserved.
//

import UIKit
import Combine
import SparkTheming
@_spi(SI_SPI) import SparkCommon

/// The UIKit version for the text editor. subclasses UITextView
public final class TextEditorUIView: UITextView {

    // MARK: - Components

    private var placeholderLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false
        return label
    }()

    // MARK: - Public Properties

    /// The textview's current theme.
    public var theme: Theme {
        get {
            return self.viewModel.theme
        }
        set {
            self.viewModel.theme = newValue
        }
    }

    /// The textview's current intent.
    public var intent: TextEditorIntent {
        get {
            return self.viewModel.intent
        }
        set {
            self.viewModel.intent = newValue
        }
    }

    /// The textview's current placeholder.
    public var placeholder: String? {
        get {
            return self.placeholderLabel.text
        }
        set {
            self.placeholderLabel.text = newValue
            self.accessibilityLabel = self.placeholder
            self.viewModel.contentChanged(with: self.text)
        }
    }

    // MARK: - Override Properties

    /// The textview's text.
    public override var text: String! {
        didSet {
            self.viewModel.contentChanged(with: self.text)
        }
    }

    /// The textview's attributedText.
    public override var attributedText: NSAttributedString! {
        didSet {
            self.viewModel.contentChanged(with: self.text)
        }
    }

    /// The textview's userInteractionEnabled.
    public override var isUserInteractionEnabled: Bool {
        didSet {
            self.viewModel.isEnabled = self.isUserInteractionEnabled
            self.accessibilityTraits
        }
    }

    /// The textview's isEditable.
    public override var isEditable: Bool {
        didSet {
            self.viewModel.isReadOnly = !self.isEditable
        }
    }

    // MARK: - Private Properties

    @ScaledUIMetric private var scaleHeight: CGFloat = TextInputConstants.height

    @ScaledUIMetric private var scaleCornerRadius: CGFloat = 0
    @ScaledUIMetric private var scaleBorderWidth: CGFloat = 0

    private var heightConstraint: NSLayoutConstraint?
    private var placeholderVerticalPaddingConstraints: [NSLayoutConstraint] = []
    private var placeholderWidthConstraint: NSLayoutConstraint?
    private var placeholderCenterYAnchorConstraint: NSLayoutConstraint?
    private var placeholderCenterXAnchorConstraint: NSLayoutConstraint?

    private let viewModel: TextEditorViewModel

    private var cancellables = Set<AnyCancellable>()

    private let notificationNames = [
        UITextView.textDidChangeNotification,
        UITextView.textDidBeginEditingNotification,
        UITextView.textDidEndEditingNotification
    ]

    // MARK: - Initialization

    /// TextEditorUIView initializer
    /// - Parameters:
    ///   - theme: The textviews's current theme
    ///   - intent: The textviews's current intent
    public init(
        theme: Theme,
        intent: TextEditorIntent
    ) {
        self.viewModel = .init(theme: theme, intent: intent)

        super.init(
            frame: .zero,
            textContainer: nil
        )

        // Setup
        self.setupView()
    }

    deinit {
        self.unsetNotificationCenter()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        // Accessibility
        self.accessibilityIdentifier = TextEditorAccessibilityIdentifier.view

        // Properties
        self.adjustsFontForContentSizeCategory = true
        self.showsHorizontalScrollIndicator = false
        self.textContainer.lineFragmentPadding = 0

        // Subviews
        self.addSubview(self.placeholderLabel)

        // Setup Observer
        self.setupNotificationCenter()

        // Setup constraints
        self.setupConstraints()

        // Setup publisher subcriptions
        self.setupSubscriptions()
    }

    // MARK: - Constraints

    private func setupConstraints() {
        self.setupViewConstraints()
        self.setupPlaceholderConstraints()
    }

    /// Setup the size constraints for this view.
    private func setupViewConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.heightConstraint = self.heightAnchor.constraint(greaterThanOrEqualToConstant: self.scaleHeight)
        self.heightConstraint?.isActive = true
    }

    /// Setup the imageView constraints.
    private func setupPlaceholderConstraints() {
        self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        self.placeholderVerticalPaddingConstraints = [
            self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.placeholderLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor)
        ]

        self.placeholderWidthConstraint = self.placeholderLabel.widthAnchor.constraint(equalTo: self.widthAnchor)
        self.placeholderCenterYAnchorConstraint = self.placeholderLabel.centerYAnchor.constraint(lessThanOrEqualTo: self.centerYAnchor)
        self.placeholderCenterXAnchorConstraint = self.placeholderLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let placeholderHorizontalConstraints = [
            self.placeholderWidthConstraint,
            self.placeholderCenterYAnchorConstraint,
            self.placeholderCenterXAnchorConstraint
        ].compactMap { $0 }

        NSLayoutConstraint.activate(self.placeholderVerticalPaddingConstraints + placeholderHorizontalConstraints)
    }

    // MARK: - Subscribe

    private func setupSubscriptions() {
        self.viewModel.$textColor.subscribe(in: &self.cancellables) { [weak self] textColor in
            guard let self else { return }
            self.textColor = textColor.uiColor
            self.tintColor = textColor.uiColor
        }

        self.viewModel.$backgroundColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] backgroundColor in
            self?.backgroundColor = backgroundColor.uiColor
        }

        self.viewModel.$borderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] borderColor in
            self?.setBorderColor(from: borderColor)
        }

        self.viewModel.$placeholderColor.removeDuplicates(by: { lhs, rhs in
            lhs.equals(rhs)
        })
        .subscribe(in: &self.cancellables) { [weak self] placeholderColor in
            self?.placeholderLabel.textColor = placeholderColor.uiColor
        }

        self.viewModel.$borderWidth.subscribe(in: &self.cancellables) { [weak self] borderWidth in
            guard let self else { return }

            self.scaleBorderWidth = borderWidth
            self._scaleBorderWidth.update(traitCollection: self.traitCollection)

            self.updateBorder()
        }

        self.viewModel.$borderRadius.subscribe(in: &self.cancellables) { [weak self] borderRadius in
            guard let self else { return }

            self.scaleCornerRadius = borderRadius
            self._scaleCornerRadius.update(traitCollection: self.traitCollection)

            self.updateBorder()
        }

        self.viewModel.$leftSpacing.subscribe(in: &self.cancellables) { [weak self] leftSpacing in
            guard let self else { return }

            self.updatePaddings(leftSpacing: leftSpacing)
        }

        self.viewModel.$rightSpacing.subscribe(in: &self.cancellables) { [weak self] rightSpacing in
            guard let self else { return }

            self.updatePaddings(rightSpacing: rightSpacing)
        }

        self.viewModel.$shouldUpdateVerticalSpacing.subscribe(in: &self.cancellables) { [weak self] _ in
            guard let self else { return }

            self.updatePaddings()
        }

        self.viewModel.$dim.removeDuplicates().subscribe(in: &self.cancellables) { [weak self] dim in
            self?.alpha = dim
        }

        self.viewModel.$font.subscribe(in: &self.cancellables) { [weak self] font in
            guard let self else { return }
            self.font = font.uiFont
            self.placeholderLabel.font = font.uiFont
        }

        self.viewModel.$isPlaceholder
            .removeDuplicates().subscribe(in: &self.cancellables) { [weak self] isPlaceholder in
                guard let self else { return }

                self.placeholderLabel.isHidden = !isPlaceholder
                self.placeholderCenterXAnchorConstraint?.isActive = isPlaceholder
                self.placeholderCenterYAnchorConstraint?.isActive = isPlaceholder
            }
    }

    // MARK: - Notification Center

    private func setupNotificationCenter() {
        for name in self.notificationNames {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(textViewFiredWithNotification(_:)),
                name: name,
                object: self
            )
        }
    }

    private func unsetNotificationCenter() {
        for name in self.notificationNames {
            NotificationCenter.default.removeObserver(
                self,
                name: name,
                object: self
            )
        }
    }

    // MARK: - Update

    private func updatePaddings(
        leftSpacing: CGFloat? = nil,
        rightSpacing: CGFloat? = nil
    ) {
        let leftSpacing = leftSpacing ?? self.viewModel.leftSpacing
        let verticalSpacing = self.viewModel.getVerticalSpacing(from: self.scaleHeight)
        let rightSpacing = rightSpacing ?? self.viewModel.rightSpacing

        // Placeholder
        if let placeholderWidthConstraint {
            placeholderWidthConstraint.constant = -(leftSpacing + rightSpacing)
        }

        for constraint in self.placeholderVerticalPaddingConstraints {
            constraint.constant = verticalSpacing
        }

        self.placeholderLabel.updateConstraintsIfNeeded()

        // Container
        self.textContainerInset = UIEdgeInsets(
            top: verticalSpacing,
            left: leftSpacing,
            bottom: verticalSpacing,
            right: rightSpacing
        )
    }

    private func updateBorder() {
        self.setCornerRadius(self.scaleCornerRadius)
        self.setBorderWidth(self.scaleBorderWidth)
    }

    // MARK: - Action

    @objc
    private func textViewFiredWithNotification(_ notification: Notification) {
        self.viewModel.contentChanged(with: self.text)
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

        // Update all Scaled variables
        self._scaleHeight.update(traitCollection: self.traitCollection)

        self._scaleCornerRadius.update(traitCollection: self.traitCollection)
        self._scaleBorderWidth.update(traitCollection: self.traitCollection)

        self.heightConstraint?.constant = self.scaleHeight
        self.updateConstraintsIfNeeded()

        self.updateBorder()

        self.viewModel.traitCollectionChanged()

        self.invalidateIntrinsicContentSize()
    }
}
