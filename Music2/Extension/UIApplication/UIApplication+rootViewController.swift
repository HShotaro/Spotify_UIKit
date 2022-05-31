//
//  UIApplication+rootViewController.swift
//  Music2
//
//  Created by Shotaro Hirano on 2022/05/20.
//

import UIKit

extension UIApplication {
    static func rootViewController() -> UIViewController {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return SplitViewController()
        default:
            return TabBarController()
        }
    }
}
