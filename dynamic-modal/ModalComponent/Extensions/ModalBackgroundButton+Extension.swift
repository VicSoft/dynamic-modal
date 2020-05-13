//
//  ModalBackgroundButton+Extension.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/29/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

extension ModalBackgroundButton {
    func fade(_ type: ModalEnum.FadeType,
              withTime: TimeInterval = 0.5,
              completion: @escaping () -> Void = { /* Optional */ }) {
        UIView.animate(withDuration: withTime, animations: {[weak self] in
            switch type {
            case .fadeIn:
                self?.alpha = 1
            case .fadeOut:
                self?.alpha = 0
            }
        }, completion: { (wasFinished) in
            if wasFinished {
                completion()
            }
        })
    }
}
