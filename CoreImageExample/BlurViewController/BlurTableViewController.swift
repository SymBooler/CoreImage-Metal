//
//  BlurTableViewController.swift
//  CoreImageExample
//
//  Created by 张广路 on 2019/11/13.
//  Copyright © 2019 symbool. All rights reserved.
//

import UIKit

class BlurTableViewController: UIViewController {
    
    enum BlurType: String, CaseIterable {
        case gaussian
        case apple
        case unsupported
    }
    
    var list: [BlurType] = [.gaussian, .apple]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .lightGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

extension BlurTableViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        case .apple:
            let vc = AppleViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .gaussian:
            let vc = GaussianBlurViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
