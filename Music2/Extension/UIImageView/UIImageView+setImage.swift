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
        let task = Task(priority: .utility) {
            self.image = await ImageLoader.shared.image(url: url, size: size)
            self.currentTask = nil
        }
        self.currentTask = task
    }
    
    func cancelCurrentLoad() {
        self.currentTask?.cancel()
        self.currentTask = nil
        self.image = UIImage(systemName: "photo")
    }
}

// 現在画像のロードを実行中のタスクを管理する
private var valueKey = 0
extension UIImageView {
    fileprivate var currentTask: Task<(), Never>? {
        get {
            return objc_getAssociatedObject(self, &valueKey) as? Task<(), Never>
        }
        set {
            objc_setAssociatedObject(self, &valueKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
