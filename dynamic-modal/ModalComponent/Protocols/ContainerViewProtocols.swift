//
//  ContainerViewProtocols.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/29/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

protocol ContainerViewTappingDelegate: class {
    func didStartDragging(_ sender: UIPanGestureRecognizer)
    func didEndDragging(_ sender: UIPanGestureRecognizer)
}
