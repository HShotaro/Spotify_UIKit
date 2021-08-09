//
//  PlayerViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapNext()
    func didTapBack()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {
    
    weak var delegate: PlayerViewControllerDelegate?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        
        imageView.clipsToBounds = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        controlsView.frame = CGRect(
            x: 10,
            y: view.height-view.safeAreaInsets.bottom-250,
            width: view.width-20,
            height: 250
        )
        
        let imageSize: CGFloat = min(view.width, view.height-view.safeAreaInsets.bottom-view.safeAreaInsets.top-250)
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: imageSize)
    }
    
    func refreshUI(audioTrack: AudioTrack?) {
        imageView.sd_setImage(with: URL(string: audioTrack?.album?.images?.first?.url ?? ""), completed: nil)
        controlsView.configure(with: PlayerControlsViewViewModel(title: audioTrack?.name, subTitle: audioTrack?.artists?.first?.name))
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapNextButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapNext()
    }
    
    func playerControlsViewDidTapBackButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBack()
    }
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
}
