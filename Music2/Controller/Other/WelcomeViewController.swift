//
//  WelcomeViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

class WelcomeViewController: UIViewController {

    private let signInButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .white
        b.setTitle("Sign In With Spotify", for: .normal)
        b.setTitleColor(.blue, for: .normal)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome Music"
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        signInButton.frame = CGRect(x: 20, y: view.height - 50 - view.safeAreaInsets.bottom, width: view.width - 40, height: 50)
        
    }
    
    @objc private func didTapSignIn() {
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "認証エラー", message: "Spotifyアカウントへのサインインに失敗しました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let mainAppTabBarVC = TabBarController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
}
