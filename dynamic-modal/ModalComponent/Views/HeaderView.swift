//
//  HeaderView.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 5/7/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class HeaderView: UIView {
    
    private var viewHeightConstraint: NSLayoutConstraint?
    private let closeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.accessibilityLabel = "abrir"
        button.accessibilityIdentifier = "toque duas vezes para abrir"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = UIColor.black.withAlphaComponent(0.9)
        title.accessibilityTraits = .header
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    private let divisorLineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    var titleText: String?
    var isArrowButton: Bool = false
    var shouldPresentLineView: Bool = true
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superview = superview {
            removeConstraints(constraints)
            
            viewHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 17)
            
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: superview.topAnchor),
                leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                viewHeightConstraint!
            ])
        }
        
        setupButton()
        setupTitle()
        setupLineView()
    }
    
    func toggleCloseButton(isUp: Bool) {
        if isUp {
            closeButton.accessibilityLabel = "fechar"
            closeButton.accessibilityIdentifier = "closeModal"
            closeButton.accessibilityHint = "toque duas vezes para fechar"
        } else {
            closeButton.accessibilityLabel = "abrir"
            closeButton.accessibilityIdentifier = "openModal"
            closeButton.accessibilityHint = "toque duas vezes para abrir"
        }
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.closeButton.transform = CGAffineTransform(rotationAngle: isUp ? CGFloat.pi : -(CGFloat.pi * 2))
            self?.layoutIfNeeded()
        }
    }
    
    // MARK: private methods
    private func setupButton() {
        var marginTop: CGFloat = .zero
        
        closeButton.isAccessibilityElement = isArrowButton
        
        if isArrowButton {
            closeButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            closeButton.backgroundColor = .clear
            closeButton.setTitleColor(UIColor.black.withAlphaComponent(0.9), for: .normal)
            closeButton.setTitle("\u{2303}", for: .normal)
        } else {
            marginTop = 16
            closeButton.frame = CGRect(x: 0, y: 0, width: 48, height: 6)
            closeButton.backgroundColor = (.gray as UIColor).withAlphaComponent(0.9)
            addRoundedCorners(for: closeButton, radius: 4)
        }
        
        addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: marginTop),
            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: closeButton.frame.width),
            closeButton.heightAnchor.constraint(equalToConstant: closeButton.frame.height)
        ])
        layoutIfNeeded()
        viewHeightConstraint?.constant += (closeButton.frame.height + marginTop)
    }
    
    private func setupTitle() {
        if titleText != nil {
            titleLabel.text = titleText
            addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 1),
                centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor)
            ])
            layoutIfNeeded()
            viewHeightConstraint?.constant += (1 + titleLabel.frame.height)
        }
    }
    
    private func setupLineView() {
        if shouldPresentLineView {
            let lastVisibleView = (titleText != nil) ? titleLabel : closeButton
            let topBottomAnchor = lastVisibleView.bottomAnchor
            
            addSubview(divisorLineView)
            NSLayoutConstraint.activate([
                divisorLineView.topAnchor.constraint(equalTo: topBottomAnchor, constant: 21),
                leadingAnchor.constraint(equalTo: divisorLineView.leadingAnchor),
                trailingAnchor.constraint(equalTo: divisorLineView.trailingAnchor),
                divisorLineView.heightAnchor.constraint(equalToConstant: 1)
            ])
            
            viewHeightConstraint?.constant += 5
            layoutIfNeeded()
        }
    }
    
    private func addRoundedCorners(for button: UIButton, radius: CGFloat) {
        let corners = UIRectCorner.allCorners
        
        if #available(iOS 11.0, *) {
            button.clipsToBounds = true
            button.layer.cornerRadius = radius
            button.layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(
                roundedRect: button.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            button.layer.mask = mask
        }
    }
}
