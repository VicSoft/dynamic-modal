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
    var draggDelegate: ContainerViewTappingDelegate?
    
    private var heightContainerAnchor: NSLayoutConstraint?
    
    init(withHeight initialHeight: CGFloat) {
        viewHeight = initialHeight
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = bgColor
        view.addSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, constant: initialViewHeight)
        ])
        view.layoutIfNeeded()
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        viewHeight = viewHeight + view.frame.height
    }
    
    // MARK: private methods
    private func setupView() {
        viewHeight = viewHeight == 0 ? 80 : viewHeight
        initialViewHeight = viewHeight
        setupPanRecognizer()
    }
    
    private func setupPanRecognizer() {
        if gestureRecognizers?.count ?? 0 > 0 { return }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(tappingViewRecognizer))
        addGestureRecognizer(panGesture)
    }
    
    @objc func tappingViewRecognizer(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed: draggDelegate?.didStartDragging(sender)
        case .ended: draggDelegate?.didEndDragging(sender)
        default: break
        }
    }
}
