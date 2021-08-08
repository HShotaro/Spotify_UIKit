//
//  PlayerViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

class PlayerViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBlue
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        
        configureBarButtons()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        controlsView.frame = CGRect(
            x: 10,
            y: view.height-view.safeAreaInsets.bottom-300,
            width: view.width-20,
            height: 300
        )
        
        let imageSize: CGFloat = min(view.width, view.height-view.safeAreaInsets.bottom-view.safeAreaInsets.top-300)
        imageView.frame = CGRect(x: (view.width-imageSize)/2, y: view.safeAreaInsets.top, width: imageSize, height: imageSize)
    }
    
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction() {
        dismiss(animated: true, completion: nil)
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        
    }
    
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView) {
        
    }
    
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView) {
        
    }
}
