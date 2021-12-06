//
//  UIImageView+setImage.swift
//  Music2
//
//  Created by Shotaro Hirano on 2021/12/06.
//

import UIKit

extension UIImageView {
    func setImageBy(_ url: URL?, contentMode: UIImageView.ContentMode = .scaleAspectFit, size: CGSize? = nil) {
        guard let url = url else {
            return
        }
        self.contentMode = contentMode
        Task(priority: .utility) {
            self.image = await ImageLoader.shared.image(url: url, size: size)
        }
    }
}
