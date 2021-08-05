//
//  UIAlertController+generate.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/06.
//

import UIKit

extension UIViewController {
    func generateAlert(error: Error, retryHandler: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "リトライ", style: .default) {  _ in
            retryHandler?()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        return alert
    }
}
