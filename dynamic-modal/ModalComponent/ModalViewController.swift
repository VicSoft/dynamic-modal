//
//  ModalViewController.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/23/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class ModalViewController: UIViewController {
    
    var canShowBackgroundOnSwipe: Bool = false
    var presentationType: ModalEnum.PresentationType = .alert
    weak var delegate: ModalViewDelegate?
    
    // view height without navigationBar
    private let parentViewHeight: CGFloat = UIScreen.main.bounds.height
    
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
        case .alert:
            show {[weak self] in
                self?.toggleBackgroundButton()
            }
        default: break
        }
    }
    
    func configure(in viewController: UIViewController) {
        let initialContainerPosition = (startModalPosition * 2)
        var parentView = view ?? UIView()
        
        switch presentationType {
        case .modal:
            // removing default constraints from system
            parentView = viewController.view ?? UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            
            modalWrapperTopConstraint = view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: initialContainerPosition)
            
            parentView.addSubview(view)
            NSLayoutConstraint.activate([
                modalWrapperTopConstraint!,
                view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
            view.layoutIfNeeded()
        default: canShowBackgroundOnSwipe = true
        }
        
        containerView.configure(in: view, withPresentation: presentationType)
        modalContainerTopConstraint = containerView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: initialContainerPosition)
        modalContainerTopConstraint?.isActive = true
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        
        callerVc = viewController
    }
    
    // MARK: necessary to improve .alert behavior
    func show(_ animationHasFinish: @escaping () -> Void = { /* Optional */ }) {
        switch presentationType {
        case .modal: present(onFinish: animationHasFinish)
        case .alert:
            callerVc?.present(self, animated: true, completion: { [weak self] in
                self?.present(onFinish: animationHasFinish)
            })
        }
    }
    
    func addView(_ view: UIView) {
        containerView.addSubview(view)
        resetPositon()
    }
    
    // MARK: private methods
    private func setupView() {
        view.backgroundColor = .clear
        containerView.draggDelegate = self
    }
    
    private func present(onFinish animationHasFinish: @escaping () -> Void) {
        let startModalPosition = parentViewHeight - initialViewHeight
        
        animate({ [weak self] in
            self?.modalContainerTopConstraint?.constant = startModalPosition
            
            switch self?.presentationType {
            case .modal?:
                self?.modalWrapperTopConstraint?.constant = startModalPosition
            default: break
            }
        }, completion: animationHasFinish)
    }
    
    private func handleModalSwipe(for sender: UIPanGestureRecognizer) {
        managerTopPosition = modalContainerTopConstraint?.constant ?? 0
        let currentTopPosition = parentViewHeight - managerTopPosition
        
        if currentTopPosition <= containerView.viewHeight && currentTopPosition >= initialViewHeight {
            managerTopPosition += sender.translation(in: containerView).y
        }
        
        modalContainerTopConstraint?.constant = managerTopPosition
        backgroundViewBottomConstraint?.constant = managerTopPosition
        
        if !canShowBackgroundOnSwipe {
            modalWrapperTopConstraint?.constant = managerTopPosition
        }
        
        view.layoutIfNeeded()
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
        
        if !canShowBackgroundOnSwipe {
            modalWrapperTopConstraint?.constant = endPosition
        }
        
        modalContainerTopConstraint?.constant = endPosition
        
        animate { [weak self] in
            if let modalClass = self {
                modalClass.delegate?.didToggleModal(for: modalClass.modalIsOpen() ? .open : .dismiss)
                modalClass.toggleBackgroundButton()
                modalClass.containerView.toggleCloseButton(modalClass.modalIsOpen())
            }
        }
    }
    
    private func dismissAlert() {
        let currentPosition = parentViewHeight - managerTopPosition
        if currentPosition >= (containerView.viewHeight * 0.5) { return }
        
        modalContainerTopConstraint?.constant = (startModalPosition * 2)
        animate(withDuration: 0.5) { [weak self] in
            self?.removeBackgroundButton()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func modalIsOpen() -> Bool {
        let topLimit = (containerView.viewHeight) * 0.6
        return (parentViewHeight - (modalContainerTopConstraint?.constant ?? 0)) > topLimit
    }
    
    private func toggleBackgroundButton() {
        if !canShowBackgroundOnSwipe || backgroundView != nil { return }

        if modalIsOpen() {
            removeBackgroundButton()
            return
        }
        
        modalWrapperTopConstraint?.constant = 0
        view.layoutIfNeeded()
        
        backgroundView = ModalBackgroundButton()
        backgroundView?.fade(.fadeOut)
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
        if !canShowBackgroundOnSwipe || isScrolling || backgroundView != nil { return }
        
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
        UIView.animate(withDuration: of, animations: { [weak self] in
            animations()
            self?.view.layoutIfNeeded()
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
}

// MARK: class protocols
extension ModalViewController: ContainerViewTappingDelegate {
    func didStartDragging(_ sender: UIPanGestureRecognizer) {
        handleModalSwipe(for: sender)
    }
    
    func didEndDragging(_ sender: UIPanGestureRecognizer) {
        switch presentationType {
        case .alert: dismissAlert()
        default: toggleModal()
        }
    }
}
