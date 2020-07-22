//
//  Modal.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/23/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class Modal: UIViewController {
    
    var canShowBackgroundOnSwipe: Bool = true
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
    
    init(withType: ModalEnum.PresentationType, initialHeight: CGFloat = 80) {
        initialViewHeight = initialHeight
        super.init(nibName: nil, bundle: nil)
        presentationType = withType
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        view.accessibilityIdentifier = "superviewArea"
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        if presentationType == .alert {
            toggleBackgroundButton()
        }
    }
    
    func configure(in viewController: UIViewController) {
        buildParentViewHeight(withVc: viewController)
        view.accessibilityIdentifier = "modal"
        let initialContainerPosition = (startModalPosition * 2)
        var parentView = view ?? UIView()
        
        switch presentationType {
        case .modal:
            // removing default constraints from system
            parentView = viewController.view ?? UIView()
            configureModal(withParent: parentView, initialPosition: initialContainerPosition)
        default: containerView.isHidden = true
        }
        
        containerView.configure(in: view, withPresentation: presentationType)
        modalContainerTopConstraint = containerView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: initialContainerPosition)
        modalContainerTopConstraint?.isActive = true
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
    }
    
    func show(_ animationHasFinished: @escaping () -> Void = { /* Optional */ }) {
        switch presentationType {
        case .modal: present(onFinish: animationHasFinished)
        case .alert: presentAlert(onFinish: animationHasFinished)
        }
    }
    
    func addView(_ view: UIView) {
        containerView.addSubview(view)
        resetPositon()
    }
    
    func close() {
        if presentationType == .alert {
            dismissAlert()
            return
        }
        
        toggleModal()
    }
    
    // MARK: private methods
    private func setupView() {
        view.backgroundColor = .clear
        containerView.draggDelegate = self
    }
    
    private func configureModal(withParent parentView: UIView, initialPosition: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        canShowBackgroundOnSwipe = false
        
        modalWrapperTopConstraint = view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: initialPosition)
        parentView.addSubview(view)
        NSLayoutConstraint.activate([
            modalWrapperTopConstraint!,
            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
        view.layoutIfNeeded()
    }
    
    private func presentAlert(onFinish animationHasFinished: @escaping () -> Void) {
        modalContainerTopConstraint?.constant = (startModalPosition * 2)
        containerView.isHidden = false
        callerVc?.present(self, animated: true) { [weak self] in
            self?.present(onFinish: animationHasFinished)
        }
    }
    
    private func present(onFinish animationHasFinished: @escaping () -> Void) {
        buildParentViewHeight(withVc: callerVc)
        
        let initialPosition = parentViewHeight - initialViewHeight
        
        animate({
            self.modalContainerTopConstraint?.constant = initialPosition
            
            switch self.presentationType {
            case .modal: self.modalWrapperTopConstraint?.constant = initialPosition
            default: break
            }
        }, completion: animationHasFinished)
    }
    
    private func buildParentViewHeight(withVc vc: UIViewController?) {
        parentViewHeight = (vc?.view.frame.height ?? parentViewHeight)
        startModalPosition = parentViewHeight - containerView.initialViewHeight
        
        if callerVc == nil {
            callerVc = vc
        }
    }
    
    private func handleModalSwipe(for sender: UIPanGestureRecognizer) {
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        
        managerTopPosition += sender.translation(in: containerView).y
        modalContainerTopConstraint?.constant = managerTopPosition
        backgroundViewBottomConstraint?.constant = managerTopPosition
        
        if !canShowBackgroundOnSwipe {
            modalWrapperTopConstraint?.constant = managerTopPosition
        }
        
        view.layoutIfNeeded()
        view.updateConstraintsIfNeeded()
        removeBackgroundButton(isScrolling: true)
        sender.setTranslation(.zero, in: containerView)
    }
    
    private func toggleModal(isForcedClose: Bool = false) {
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        let isModalOpenned = ((modalIsOpen() || managerTopPosition == startModalPosition) && (!isForcedClose || !modalIsOpen()))
        let endPosition = isModalOpenned ? parentViewHeight - containerView.viewHeight : startModalPosition
        
        modalWrapperTopConstraint?.constant = !canShowBackgroundOnSwipe ? endPosition : (modalWrapperTopConstraint?.constant ?? 0)
        modalContainerTopConstraint?.constant = endPosition
        
        animate {
            self.delegate?.didToggleModal(for: self.modalIsOpen() ? .open : .dismiss)
            self.toggleBackgroundButton()
            self.containerView.toggleCloseButton(self.modalIsOpen())
        }
    }
    
    private func dismissAlert() {
        modalContainerTopConstraint?.constant = (startModalPosition * 2)
        
        animate(withDuration: 0.5) {
            self.removeBackgroundButton()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func modalIsOpen() -> Bool {
        let topLimit = (containerView.viewHeight * 0.65)
        return (parentViewHeight - (modalContainerTopConstraint?.constant ?? 0)) > topLimit
    }
    
    private func toggleBackgroundButton() {
        if !canShowBackgroundOnSwipe || backgroundView != nil {
            return
        }

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
        if !canShowBackgroundOnSwipe || isScrolling || backgroundView != nil {
            return
        }
        
        let modalTopPosition = parentViewHeight - initialViewHeight
        
        backgroundView?.fade(.fadeOut, withTime: 0.5) {
            self.modalWrapperTopConstraint?.constant = modalTopPosition
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        }
    }
    
    private func animate(_ animations: @escaping () -> Void = { /* Optional */ },
                         withDuration of: TimeInterval = 0.25,
                         completion: @escaping () -> Void = { /* Optional */ }) {
        UIView.animate(withDuration: of, animations: {
            animations()
            self.view.layoutIfNeeded()
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
        close()
    }
}

// MARK: class protocols
extension Modal: ContainerViewTappingDelegate {
    func didStartDragging(_ sender: UIPanGestureRecognizer) {
        handleModalSwipe(for: sender)
    }
    
    func didEndDragging(_ sender: UIPanGestureRecognizer) {
        close()
    }
    
    func didTapToggleButton() {
        toggleModal(isForcedClose: true)
    }
}
