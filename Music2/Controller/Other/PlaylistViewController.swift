//
//  PlaylistViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

class PlaylistViewController: UIViewController {
    private let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
        // Group
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60)),
            subitem: item,
            count: 1
        )
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }))
    
    var isOwner = false
    let playlistID: String
    
    init(playlistID: String) {
        self.playlistID = playlistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tracks = [AudioTrack]()
    private var viewModels = [PlaylistCellViewModel]()
    private var headerViewModel: PlaylistHeaderViewViewModel?
    private var shareViewModel: (urlString: String, title: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        fetchPlaylistData(playlistID: playlistID)
        if isOwner {
            addLongTapGesture()
        }
    }
    
    @objc private func didTapShare() {
        guard let shareViewModel = shareViewModel, let url = URL(string: shareViewModel.urlString) else {
            return
        }
        let vc = UIActivityViewController(activityItems: [shareViewModel.title, url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
        
        let track = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: track.name, message: "Would you like to delete this from a playlist", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "delete from Playlist", style: .destructive, handler: { [weak self] _ in
            self?.delete(track: track, from: self?.playlistID ?? "", indexPath: indexPath)
        }))
        present(actionSheet, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchPlaylistData(playlistID: String) {
        APICaller.shared.getPlaylistDetails(for: playlistID) { [weak self] result in
            switch result {
            case let .success(model):
                self?.tracks = model.tracks.items.compactMap({ $0.track})
                self?.viewModels = model.tracks.items.compactMap({ playList in
                    PlaylistCellViewModel(name: playList.track.name, artistName: playList.track.artists?.first?.name ?? "", artworkURL: URL(string: playList.track.album?.images?.first?.url ?? ""))
                })
                
                self?.headerViewModel = PlaylistHeaderViewViewModel(name: model.name, artworkURL: URL(string: model.images.first?.url ?? ""))
                self?.shareViewModel = (urlString: model.external_urls["spotify"] ?? "", title: model.description)
                DispatchQueue.main.async {
                    self?.title = model.name
                    self?.collectionView.reloadData()
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchPlaylistData(playlistID: playlistID)
                }) else { return }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func delete(track: AudioTrack, from playlistID: String, indexPath: IndexPath) {
        APICaller.shared.removeTrackFromPlaylists(track: track, playlistID: playlistID) { [weak self] result in
            switch result {
            case .success:
                let alert = UIAlertController(title: "", message: "Removed \(track.name)", preferredStyle: .alert)
                DispatchQueue.main.async {
                    HapticsManager.shared.vibrate(for: .success)
                    self?.tracks.remove(at: indexPath.row)
                    self?.viewModels.remove(at: indexPath.row)
                    self?.collectionView.reloadData()
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.delete(track: track, from: playlistID, indexPath: indexPath)
                }) else { return }
                DispatchQueue.main.async {
                    HapticsManager.shared.vibrate(for: .error)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension PlaylistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.identifier, for: indexPath) as? PlaylistCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else { return UICollectionReusableView() }
        
        header.configure(with: self.headerViewModel)
        header.delegate = self
        return header
    }
}

extension PlaylistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(
            from: self,
            tracks: tracks
        )
    }
}
