//
//  TableViewController.swift
//  dynamic-modal
//
//  Created by Victor Barbosa on 4/27/20.
//  Copyright © 2020 VicSoft Sistemas. All rights reserved.
//

import UIKit

final class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        tableView = UITableView(frame: tableView.frame, style: .grouped
        )
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewId")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}
