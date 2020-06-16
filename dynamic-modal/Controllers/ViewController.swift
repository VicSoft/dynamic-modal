//
//  ViewController.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/23/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class CustomCell: UITableViewCell { }

class ViewController: UIViewController {
    
    var modalView: ModalViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    private func setupView() {
        view.backgroundColor = (.red as UIColor).withAlphaComponent(0.5)
        
        modalView = ModalViewController(withType: .modal(title: "Título da modal"), initialHeight: 88)
        modalView?.delegate = self
        modalView?.configure(in: self)
        modalView?.addView(getTableView())
    }
    
    private func getTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 174), style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewId")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        
        return tableView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        modalView?.show()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewId", for: indexPath)
        
        switch indexPath.row {
        case 0: cell.textLabel?.text = "Linha 1"
        case 1: cell.textLabel?.text = "Linha 2"
        case 2: cell.textLabel?.text = "Linha 3"
        case 3: cell.textLabel?.text = "Linha 4"
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}


extension ViewController: ModalViewDelegate {
    func didToggleModal(for state: ModalEnum.State) {
        switch state {
        case .open: print("modal openned")
        case .dismiss: print("modal closed")
        }
    }
}
