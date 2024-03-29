//
//  ViewController.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/10/31.
//  Copyright © 2019 symbool. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    enum CoreImageType: String, CaseIterable {
        case blur
        case transition
        case unsupported
    }
    
    var list = CoreImageType.allCases.dropLast()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .lightGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.textLabel?.text = list[indexPath.row].rawValue
        cell?.textLabel?.textColor = .systemPurple
        cell?.backgroundColor = .systemBackground
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch list[indexPath.row] {
        case .blur:
            let vc = BlurTableViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .transition:
            let vc = TransitionTableViewController()
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
        
    }
}
