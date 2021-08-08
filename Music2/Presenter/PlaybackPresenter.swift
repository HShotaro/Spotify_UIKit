//
//  PlaybackPresenter.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import UIKit

final class PlaybackPresenter {
    static func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ) {
        let vc = PlayerViewController()
        let nav = NavigationController.init(rootViewController: vc)
        viewController.present(nav, animated: true, completion: nil)
        
    }
    
    static func startPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ) {
        let vc = PlayerViewController()
        let nav = NavigationController.init(rootViewController: vc)
        viewController.present(nav, animated: true, completion: nil)
    }
}
