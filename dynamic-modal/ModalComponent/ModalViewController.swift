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
    var presentationType: ModalEnum.PresentationType = .modal
    var delegate: ModalViewDelegate?
    
    // view height without navigationBar
    private let parentViewHeight: CGFloat = UIScreen.main.bounds.height
    
    private var containerView: ContainerView = ContainerView(withHeight: 80)
    private var initialViewHeight: CGFloat = 0
    private var modalContainerTopConstraint: NSLayoutConstraint?
    private var modalWrapperTopConstraint: NSLayoutConstraint?
    private var backgroundViewBottomConstraint: NSLayoutConstraint?
    private var backgroundView: BackgroundButton?
    private lazy var startModalPosition = parentViewHeight - containerView.initialViewHeight
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withType: ModalEnum.PresentationType) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentationType == .alert {
            animate({[weak self] in
                self?.modalWrapperTopConstraint?.constant = self?.startModalPosition ?? 0
                self?.modalContainerTopConstraint?.constant = self?.startModalPosition ?? 0
            }, completion: {
                self.addBackgroundButton()
            })
        }
    }
    
    func configure(in parentView: UIView) {
        if presentationType == .modal {
            // removing default constraints from system
            view.translatesAutoresizingMaskIntoConstraints = false
            modalWrapperTopConstraint = view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: (startModalPosition * 2))
            
            parentView.addSubview(view)
            
            NSLayoutConstraint.activate([
                modalWrapperTopConstraint!,
                view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])
            view.layoutIfNeeded()
            containerView.configure(in: view)
            modalContainerTopConstraint = containerView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: (startModalPosition * 2))
            modalContainerTopConstraint?.isActive = true
        } else {
            canShowBackgroundOnSwipe = true
            containerView.configure(in: view)
            modalContainerTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: (startModalPosition * 2))
            modalContainerTopConstraint?.isActive = true
        }
    }
    
    func show() {
        if presentationType == .modal {
            animate({[weak self] in
                self?.modalWrapperTopConstraint?.constant = self?.startModalPosition ?? 0
                self?.modalContainerTopConstraint?.constant = self?.startModalPosition ?? 0
            })
        } else {
            // MARK: check to make call by self class
            UIApplication.shared.inputViewController?.present(self, animated: true, completion: nil)
        }
    }
    
    func addView(_ view: UIView) {
        containerView.addSubview(view)
        
        if presentationType == .alert {
            startModalPosition = (parentViewHeight - containerView.viewHeight)
            modalContainerTopConstraint?.constant = startModalPosition * 2
        }
    }
    
    // MARK: private methods
    private func setupView() {
        view.backgroundColor = .clear
        switch presentationType {
        case .modal: containerView = ContainerView(withHeight: 80)
        case .alert: containerView = ContainerView(withHeight: 140)
        }
        containerView.draggDelegate = self
        initialViewHeight = containerView.viewHeight
    }
    
    private func handleModalSwipe(for sender: UIPanGestureRecognizer) {
        if var managerTopPosition = modalContainerTopConstraint?.constant {
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
        }
        sender.setTranslation(.zero, in: containerView)
    }
    
    private func toggleModal() {
        if let modalTopPosition = modalContainerTopConstraint?.constant {
            let currentTopPosition = parentViewHeight - modalTopPosition
            var endPosition = startModalPosition
            
            //if currentTopPosition == initialViewHeight ||
            if currentTopPosition > (containerView.viewHeight * 0.60) {
                endPosition = parentViewHeight - containerView.viewHeight
            }
            
            if !canShowBackgroundOnSwipe {
                modalWrapperTopConstraint?.constant = endPosition
            }
            
            modalContainerTopConstraint?.constant = endPosition
            
            toggleModalIconButton()
        }
    }
    
    private func handleSwipeAlert(for sender: UIPanGestureRecognizer) {
        if var managerTopPosition = modalContainerTopConstraint?.constant {
            let currentTopPosition = parentViewHeight - managerTopPosition
            
            if currentTopPosition <= containerView.viewHeight && currentTopPosition >= initialViewHeight {
                managerTopPosition += sender.translation(in: containerView).y
            }
            
            modalContainerTopConstraint?.constant = managerTopPosition
            backgroundViewBottomConstraint?.constant = managerTopPosition
            view.layoutIfNeeded()
            removeBackgroundButton(isScrolling: true)
        }
        sender.setTranslation(.zero, in: containerView)
    }
    
    private func dismissAlert() {
        modalContainerTopConstraint?.constant = (startModalPosition * 2)
        animate({}, withDuration: 0.5, completion: {
            self.removeBackgroundButton()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func toggleModalIconButton() {
        let isOpen = (parentViewHeight - (modalContainerTopConstraint?.constant ?? 0)) >= (containerView.viewHeight * 0.5)
        
        animate({}) {[weak self] in
            if isOpen {
                self?.delegate?.handleModalOpening()
                self?.addBackgroundButton()
                return
            }
            self?.delegate?.handleModalClosing()
            self?.removeBackgroundButton()
        }
    }
    
    private func animate(_ animations: @escaping () -> Void, withDuration of: TimeInterval = 0.25, completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: of, animations: { [weak self] in
            animations()
            self?.view.layoutIfNeeded()
        }, completion: {(wasFinished) in
            if wasFinished {
                completion()
            }
        })
    }
    
    private func addBackgroundButton() {
        if !canShowBackgroundOnSwipe { return }

        if backgroundView == nil {
            modalWrapperTopConstraint?.constant = 0
            view.layoutIfNeeded()
            
            backgroundView = BackgroundButton()
            
            backgroundView?.translatesAutoresizingMaskIntoConstraints = false
            backgroundView?.backgroundColor = (.black as UIColor).withAlphaComponent(0.5)
            backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundView?.fadeOut()
            
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
            backgroundView?.fadeIn()
        }
    }
    
    func removeBackgroundButton(isScrolling: Bool = false) {
        if !canShowBackgroundOnSwipe || isScrolling { return }
        
        if backgroundView != nil {
            backgroundView?.fadeOut(withTime: 0.5, completion: {[weak self] in
                if let selfClass = self {
                    selfClass.modalWrapperTopConstraint?.constant = selfClass.parentViewHeight - selfClass.initialViewHeight
                }
                self?.backgroundView?.removeFromSuperview()
                self?.backgroundView = nil
            })
        }
    }
}

// MARK: class protocols
extension ModalViewController: ContainerViewTappingDelegate {
    func didStartDragging(_ sender: UIPanGestureRecognizer) {
        handleModalSwipe(for: sender)
    }
    
    func didEndDragging(_ sender: UIPanGestureRecognizer) {
        if presentationType == .alert {
            if let modalTopPosition = modalContainerTopConstraint?.constant {
                let currentTopPosition = parentViewHeight - modalTopPosition
                if currentTopPosition <= (containerView.viewHeight * 0.5) {
                    dismissAlert()
                    return
                }
            }
            
        }
        toggleModal()
    }
}
