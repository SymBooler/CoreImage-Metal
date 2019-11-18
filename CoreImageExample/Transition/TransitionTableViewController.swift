//
//  TransitionTableViewController.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/11/13.
//  Copyright © 2019 symbool. All rights reserved.
//

import UIKit

class TransitionTableViewController: UIViewController {
    
    enum TransitionType: String, CaseIterable {
        case swipe
        case unsupported
    }
    
    var list = TransitionType.allCases.dropLast()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .lightGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

extension TransitionTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.textLabel?.text = list[indexPath.row].rawValue
        cell?.textLabel?.textColor = .systemPurple
        cell?.backgroundColor = .systemBackground
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch list[indexPath.row] {
        case .swipe:
            let vc = SwipeTransitionController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
