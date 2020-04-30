//
//  HomeProtocol.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/23/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

protocol HomeRoutingLogicProtocol {
    var viewController: UIViewController? { get set }
    func route(to flow: HomeEnum.RouterFlow)
}
