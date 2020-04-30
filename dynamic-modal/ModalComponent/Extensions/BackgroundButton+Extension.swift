//
//  BackgroundButton+Extension.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/29/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

extension BackgroundButton {
    func fadeIn(withTime: TimeInterval = 0.5, completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: withTime, animations: {[weak self] in
            self?.alpha = 1
        }, completion: { (wasFinished) in
            if wasFinished {
                completion()
            }
        })
    }
    
    func fadeOut(withTime: TimeInterval = 0.5, completion: @escaping () -> Void = {}) {
        UIView.animate(withDuration: withTime, animations: {[weak self] in
            self?.alpha = 0
        }, completion: { (wasFinished) in
            if wasFinished {
                completion()
            }
        })
    }
}
