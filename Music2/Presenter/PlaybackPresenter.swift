//
//  PlaybackPresenter.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import UIKit
import AVFoundation

final class PlaybackPresenter {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    
    @objc private func itemDidPlayToEnd() {
        if playerQueue != nil, let currentID = audioTrackID {
            guard let index = (tracks.firstIndex { $0.id == currentID}),
                  index + 1 < tracks.count else {
                playFirstAudioTrack()
                return
            }
            playerQueue?.advanceToNextItem()
            self.audioTrackID = tracks[index+1].id
            playerVC?.refreshUI(audioTrack: tracks[index+1])
        }
        
    }
    static let shared = PlaybackPresenter()
    
    private var audioTrackID: String?
    private var tracks = [AudioTrack]()
    
    var playerVC: PlayerViewController?
    var playerQueue: AVQueuePlayer?
    
    func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ) {
        guard let url = URL(string: track.preview_url ?? "") else { return }
        playerQueue = nil
        
        self.tracks = [track]
        playerQueue = AVQueuePlayer(url: url)
        let vc = PlayerViewController()
        vc.delegate = self
        let nav = NavigationController.init(rootViewController: vc)
        viewController.present(nav, animated: true) { [weak self] in
            self?.playerQueue?.play()
            self?.audioTrackID = track.id
            vc.refreshUI(audioTrack: track)
            self?.playerVC = vc
        }
        
    }
    
    func startPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ) {
        let rawTracks = tracks.filter{ URL(string: $0.preview_url ?? "") != nil }
        let isSameOfPrevTracks = self.tracks.isSameOf(rawTracks)
        if !isSameOfPrevTracks {
            playerQueue = nil
            self.tracks = rawTracks.shuffled()
            let items: [AVPlayerItem] = self.tracks.compactMap {
                guard let url = URL(string: $0.preview_url ?? "") else { return nil }
                return AVPlayerItem(url: url)
            }
            self.playerQueue = AVQueuePlayer(items: items)
        }
        
        
        let vc = PlayerViewController()
        vc.delegate = self
        let nav = NavigationController.init(rootViewController: vc)
        viewController.present(nav, animated: true) { [weak self] in
            self?.playerQueue?.play()
            self?.playerVC = vc
            if isSameOfPrevTracks {
                let track = self?.tracks.first { $0.id == self?.audioTrackID }
                vc.refreshUI(audioTrack: track)
            } else {
                vc.refreshUI(audioTrack: self?.tracks.first)
                self?.audioTrackID = self?.tracks.first?.id
            }
        }
    }
    
    func playFirstAudioTrack() {
        self.tracks = tracks.shuffled()
        let items: [AVPlayerItem] = tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else { return nil }
            return AVPlayerItem(url: url)
        }
        guard items.count > 0 else { return }
        self.audioTrackID = tracks.first?.id
        playerQueue = AVQueuePlayer(items: items)
        playerQueue?.play()
        playerVC?.refreshUI(audioTrack: tracks.first)
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = playerQueue {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapNext() {
        if playerQueue != nil, let currentID = audioTrackID {
            guard let index = (tracks.firstIndex { $0.id == currentID}),
                  index + 1 < tracks.count else {
                playFirstAudioTrack()
                return
            }
            playerQueue?.advanceToNextItem()
            self.audioTrackID = tracks[index+1].id
            playerVC?.refreshUI(audioTrack: tracks[index+1])
        }
        
    }
    
    func didTapBack() {
        if let currentItem = playerQueue?.currentItem, let currentID = audioTrackID {
            let index = tracks.firstIndex { $0.id == currentID } ?? 0
            let currentTrack = tracks[index]
            guard let url = URL(string: currentTrack.preview_url ?? "")
            else { return }
            playerQueue?.insert(AVPlayerItem(url: url), after: currentItem)
            
            playerQueue?.remove(currentItem)
            self.audioTrackID = currentTrack.id
            playerVC?.refreshUI(audioTrack: currentTrack)
        }
    }
    
    func didSlideSlider(_ value: Float) {
        playerQueue?.volume = value
    }
}
