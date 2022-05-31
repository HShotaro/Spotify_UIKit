//
//  TabBarController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

class TabBarController: UITabBarController {
    enum TabType: Int, CaseIterable {
    case home = 0
    case search
    case library
        
        func translateToViewController() -> UIViewController {
            switch self {
            case .home:
                let vc = HomeViewController()
                vc.title = "Browse"
                return vc
            case .search:
                let vc = SearchViewController()
                vc.title = "Search"
                return vc
            case .library:
                let vc = LibraryViewController()
                vc.title = "Library"
                return vc
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navs: [UIViewController] = TabBarController.TabType.allCases.map { t in
            let vc = t.translateToViewController()
            let nav = NavigationController(rootViewController: vc)
            switch t {
            case .home:
                nav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
            case .search:
                nav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
            case .library:
                nav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 2)
            }
            return nav
        }
        
        setViewControllers(navs, animated: false)
        self.tabBar.isHidden = UIDevice.current.userInterfaceIdiom == .pad
    }
}
