//
//  HomeRouter.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/23/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class HomeRouter: HomeRoutingLogicProtocol {
    var viewController: UIViewController?
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func route(to flow: HomeEnum.RouterFlow) {
        switch flow {
        case .back:
            viewController?.dismiss(animated: true, completion: nil)
        case .modal: break
        }
    }

}
