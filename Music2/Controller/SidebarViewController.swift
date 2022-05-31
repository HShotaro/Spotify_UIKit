//
//  SideBarViewController.swift
//  Music2
//
//  Created by Shotaro Hirano on 2022/05/20.
//

import UIKit
import Foundation

class SidebarViewController: UIViewController {
    var tabBar: UITabBarController? {
        let splitVC = (UIApplication.window()?.rootViewController as? SplitViewController)
        let tabbar = splitVC?.viewControllers.filter { $0 is TabBarController }.first as? TabBarController
        return tabbar
        
    }
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension SidebarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TabBarController.TabType.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        
        if tabBar?.selectedIndex == indexPath.row  {
            cell.textLabel?.textColor = .label
            cell.imageView?.tintColor = .label
        } else {
            cell.textLabel?.textColor = .systemGray
            cell.imageView?.tintColor = .systemGray
        }
        
        switch TabBarController.TabType.allCases[indexPath.row] {
        case .home:
            cell.imageView?.image = UIImage(systemName: "house")
            cell.textLabel?.text = "Home"
        case .search:
            cell.textLabel?.text = "Search"
            cell.imageView?.image = UIImage(systemName: "magnifyingglass")
        case .library:
            cell.textLabel?.text = "Library"
            cell.imageView?.image = UIImage(systemName: "music.note.list")
        }
        return cell
    }
}

extension SidebarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let tabbar = tabBar else { return }
        guard tabbar.selectedIndex != indexPath.row else {
            let selectedVC = tabbar.viewControllers?[indexPath.row] as? NavigationController
            selectedVC?.popToRootViewController(animated: true)
            return
        }
        tabbar.selectedIndex = indexPath.row
        tableView.reloadData()
    }
}
