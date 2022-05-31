//
//  SplitViewController.swift
//  Music2
//
//  Created by Shotaro Hirano on 2022/05/20.
//

import UIKit

class SplitViewController: UISplitViewController {
    
    
    init() {
        super.init(style: .doubleColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredPrimaryColumnWidth = 180
        self.setViewController(SidebarViewController(), for: .primary)
        self.setViewController(TabBarController(), for: .secondary)
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        delegate = self
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    
}
