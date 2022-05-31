//
//  UIApplication+window.swift
//  Music2
//
//  Created by Shotaro Hirano on 2022/05/20.
//

import UIKit

extension UIApplication {
    static func window() -> UIWindow? {
        let scene: UIScene? = UIApplication.shared.connectedScenes.first { s in
            return s.session.configuration.name == "Default Configuration"
        }
        return (scene?.delegate as? SceneDelegate)?.window
    }
}
