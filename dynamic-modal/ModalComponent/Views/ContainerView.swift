//
//  ContainerView.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/29/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class ContainerView: UIView {
    var viewHeight: CGFloat = 0
    var initialViewHeight: CGFloat = 0
    var bgColor: UIColor = .white
    
    weak var draggDelegate: ContainerViewTappingDelegate?
    
    private var heightContainerAnchor: NSLayoutConstraint?
    private var header: HeaderView?
    
    init(withHeight initialHeight: CGFloat) {
        viewHeight = initialHeight
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubview(_ view: UIView) {
        let lastTopPos = (subviews.last?.frame.maxY ?? 0)
        super.addSubview(view)
        
        if !view.isKind(of: HeaderView.self) {
            view.frame.origin.y = lastTopPos
            viewHeight = viewHeight + view.frame.height
        }
    }
    
    func configure(in view: UIView, withPresentation presentation: ModalEnum.PresentationType) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = bgColor
        accessibilityIdentifier = "containerArea"
        view.addSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, constant: initialViewHeight)
        ])
        view.layoutIfNeeded()
        addHeader(with: presentation)
    }
    
    func toggleCloseButton(_ isUp: Bool) {
        header?.toggleCloseButton(isUp: isUp)
    }
    
    @objc func tappingViewRecognizer(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed: draggDelegate?.didStartDragging(sender)
        case .ended: draggDelegate?.didEndDragging(sender)
        default: break
        }
    }
    
    // MARK: private methods
    private func setupView() {
        viewHeight = viewHeight == 0 ? 80 : viewHeight
        initialViewHeight = viewHeight
        setupPanRecognizer()
        addRoundedCorners(for: self, radius: 8)
    }
    
    private func addHeader(with presentationType: ModalEnum.PresentationType) {
        header = HeaderView()
        
        switch presentationType {
        case .modal(let title):
            header?.titleText = title
            header?.shouldPresentLineView = true
            header?.isArrowButton = true
        case .alert:
            header?.isArrowButton = false
            header?.titleText = nil
            header?.shouldPresentLineView = false
        }
        
        addSubview(header!)
        header?.setupView()
        layoutIfNeeded()
    }
    
    private func setupPanRecognizer() {
        if gestureRecognizers == nil {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(tappingViewRecognizer))
            addGestureRecognizer(panGesture)
        }
    }
    
    private func addRoundedCorners(for view: UIView, radius: CGFloat) {
        let corners: UIRectCorner = [ .topLeft, .topRight ]
        
        if #available(iOS 11.0, *) {
            view.clipsToBounds = true
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(
                roundedRect: view.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
}
