//
//  ModalViewProtocols.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/29/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

protocol ModalViewDelegate: class {
    func didToggleModal(for state: ModalEnum.State)
    func handleModalOpening()
    func handleModalClosing()
}
