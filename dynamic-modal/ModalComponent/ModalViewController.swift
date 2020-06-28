//
//  ModalViewController.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/23/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class ModalViewController: UIViewController {
    
    var canShowBackgroundOnSwipe: Bool?
    var presentationType: ModalEnum.PresentationType = .alert
    weak var delegate: ModalViewDelegate?
    
    // view height without navigationBar
    private var parentViewHeight: CGFloat = UIScreen.main.bounds.height
    private var initialViewHeight: CGFloat
    private var managerTopPosition: CGFloat = 0
    private var modalContainerTopConstraint: NSLayoutConstraint?
    private var modalWrapperTopConstraint: NSLayoutConstraint?
    private var backgroundViewBottomConstraint: NSLayoutConstraint?
    private var backgroundView: ModalBackgroundButton?
    private var callerVc: UIViewController?
    private lazy var containerView: ContainerView = ContainerView(withHeight: initialViewHeight)
    private lazy var startModalPosition = parentViewHeight - containerView.initialViewHeight
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withType: ModalEnum.PresentationType, initialHeight: CGFloat = 80) {
        initialViewHeight = initialHeight
        super.init(nibName: nil, bundle: nil)
        presentationType = withType
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.accessibilityIdentifier = "superviewArea"
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetPositon()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch presentationType {
        case .alert: toggleBackgroundButton()
        default: break
        }
    }
    
    func configure(in viewController: UIViewController) {
        var heightDiff = (viewController.view.bounds.height - parentViewHeight)
        
        if heightDiff < 100 {
            var statusBarHeight = UIApplication.shared.statusBarFrame.height
            
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            }
            
            let toolbarHeight = ((viewController.navigationController?.navigationBar.frame.height ?? 0) + statusBarHeight)
            heightDiff = heightDiff + toolbarHeight
        }
        
        parentViewHeight = viewController.view.bounds.height - heightDiff
        startModalPosition = parentViewHeight - containerView.initialViewHeight
        
        let initialContainerPosition = (startModalPosition * 2)
        var parentView = view ?? UIView()
        
        switch presentationType {
        case .modal:
            // removing default constraints from system
            parentView = viewController.view ?? UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            canShowBackgroundOnSwipe = false
            
            modalWrapperTopConstraint = view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: initialContainerPosition)
            
            parentView.addSubview(view)
            NSLayoutConstraint.activate([
                modalWrapperTopConstraint!,
                view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
            view.layoutIfNeeded()
        default:
            containerView.isHidden = true
            canShowBackgroundOnSwipe = canShowBackgroundOnSwipe != nil ? canShowBackgroundOnSwipe : true
        }
        
        containerView.configure(in: view, withPresentation: presentationType)
        modalContainerTopConstraint = containerView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: initialContainerPosition)
        modalContainerTopConstraint?.isActive = true
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        
        callerVc = viewController
    }
    
    func show(_ animationHasFinish: @escaping () -> Void = { /* Optional */ }) {
        switch presentationType {
        case .modal: present(onFinish: animationHasFinish)
        case .alert:
            modalContainerTopConstraint?.constant = (startModalPosition * 2)
            containerView.isHidden = false
            callerVc?.present(self, animated: true) {[weak self] in
                self?.present(onFinish: animationHasFinish)
            }
        }
    }
    
    func addView(_ view: UIView) {
        containerView.addSubview(view)
        resetPositon()
    }
    
    func close() {
        switch presentationType {
        case .alert: dismissAlert()
        default: toggleModal()
        }
    }
    
    // MARK: private methods
    private func setupView() {
        view.backgroundColor = .clear
        containerView.draggDelegate = self
    }
    
    private func present(onFinish animationHasFinish: @escaping () -> Void) {
        let startModalPosition = parentViewHeight - initialViewHeight
        
        animate({
            self.modalContainerTopConstraint?.constant = startModalPosition
            
            switch self.presentationType {
            case .modal: self.modalWrapperTopConstraint?.constant = startModalPosition
            default: break
            }
        }, completion: animationHasFinish)
    }
    
    private func handleModalSwipe(for sender: UIPanGestureRecognizer) {
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        
        managerTopPosition += sender.translation(in: containerView).y
        modalContainerTopConstraint?.constant = managerTopPosition
        backgroundViewBottomConstraint?.constant = managerTopPosition
        
        if canShowBackgroundOnSwipe == false {
            modalWrapperTopConstraint?.constant = managerTopPosition
        }
        
        view.layoutIfNeeded()
        view.updateConstraintsIfNeeded()
        removeBackgroundButton(isScrolling: true)
        sender.setTranslation(.zero, in: containerView)
    }
    
    private func toggleModal() {
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        let currentTopPosition = parentViewHeight - managerTopPosition
        let topLimit = (containerView.viewHeight * 0.6)
        var endPosition = startModalPosition
        
        if currentTopPosition > topLimit {
            endPosition = parentViewHeight - containerView.viewHeight
        }
        
        if canShowBackgroundOnSwipe == false {
            modalWrapperTopConstraint?.constant = endPosition
        }
        
        modalContainerTopConstraint?.constant = endPosition
        
        animate {
            self.delegate?.didToggleModal(for: self.modalIsOpen() ? .open : .dismiss)
            self.toggleBackgroundButton()
            self.containerView.toggleCloseButton(self.modalIsOpen())
        }
    }
    
    private func dismissAlert(isForcedDismiss: Bool = false) {
        let currentPosition = parentViewHeight - managerTopPosition
        var initialPosition = startModalPosition * 2
        
        if currentPosition >= (containerView.viewHeight * 0.5) && !isForcedDismiss {
            initialPosition = startModalPosition
        }
        
        modalContainerTopConstraint?.constant = initialPosition
        
        if canShowBackgroundOnSwipe == true {
            backgroundViewBottomConstraint = backgroundView!.bottomAnchor.constraint(equalTo: containerView.topAnchor)
            backgroundViewBottomConstraint?.isActive = true
        }
        
        animate(withDuration: 0.5) {
            if self.startModalPosition != initialPosition {
                self.removeBackgroundButton()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func modalIsOpen() -> Bool {
        let topLimit = (containerView.viewHeight) * 0.6
        return (parentViewHeight - (modalContainerTopConstraint?.constant ?? 0)) > topLimit
    }
    
    private func toggleBackgroundButton() {
        if canShowBackgroundOnSwipe == false || backgroundView != nil { return }

        if modalIsOpen() {
            removeBackgroundButton()
            return
        }
        
        modalWrapperTopConstraint?.constant = 0
        view.layoutIfNeeded()
        
        backgroundView = ModalBackgroundButton()
        backgroundView?.fade(.fadeOut)
        backgroundView?.addTarget(self, action: #selector(closeModalAction), for: .touchUpInside)
        backgroundViewBottomConstraint = backgroundView!.bottomAnchor.constraint(equalTo: containerView.topAnchor)
        
        view.addSubview(backgroundView!)
        NSLayoutConstraint.activate([
            backgroundView!.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView!.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundView!.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundViewBottomConstraint!
        ])
        view.layoutIfNeeded()
        view.bringSubviewToFront(containerView)
        backgroundView?.fade(.fadeIn)
    }
        
    private func removeBackgroundButton(isScrolling: Bool = false) {
        if canShowBackgroundOnSwipe == false || isScrolling || backgroundView != nil { return }
        
        let modalTopPosition = parentViewHeight - initialViewHeight
        
        backgroundView?.fade(.fadeOut, withTime: 0.5) { [weak self] in
            self?.modalWrapperTopConstraint?.constant = modalTopPosition
            self?.backgroundView?.removeFromSuperview()
            self?.backgroundView = nil
        }
    }
    
    private func animate(_ animations: @escaping () -> Void = { /* Optional */ },
                         withDuration of: TimeInterval = 0.25,
                         completion: @escaping () -> Void = { /* Optional */ }) {
        UIView.animate(withDuration: of, animations: {
            animations()
            self.view.layoutIfNeeded()
            self.view.updateConstraintsIfNeeded()
        }, completion: {(wasFinished) in
            if wasFinished { completion() }
        })
    }
    
    private func resetPositon() {
        let hiddenPosition = (parentViewHeight - containerView.viewHeight) * 2
        modalContainerTopConstraint?.constant = hiddenPosition
        
        switch presentationType {
        case .modal:
            modalWrapperTopConstraint?.constant = hiddenPosition
        default: break
        }
        containerView.toggleCloseButton(false)
    }
    
    @objc private func closeModalAction() {
        switch presentationType {
        case .alert: dismissAlert(isForcedDismiss: true)
        default: toggleModal()
        }
    }
}

// MARK: class protocols
extension ModalViewController: ContainerViewTappingDelegate {
    func didStartDragging(_ sender: UIPanGestureRecognizer) {
        handleModalSwipe(for: sender)
    }
    
    func didEndDragging(_ sender: UIPanGestureRecognizer) {
        close()
    }
}
