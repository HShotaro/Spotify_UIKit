//
//  ArtistViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/09.
//

import UIKit

class ArtistViewController: UIViewController {
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
    
    let artistID: String
    
    init(artistID: String) {
        self.artistID = artistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tracks = [AudioTrack]()
    private var viewModels = [PlaylistCellViewModel]()
    private var headerViewModel: PlaylistHeaderViewViewModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchArtistTopTracksData(artistID: artistID)
        addLongTapGesture()
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
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
        
        let actionSheet = UIAlertController(title: track.name, message: "Would you like to add this to a playlist", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    vc.dismiss(animated: true, completion: nil)
                    self?.add(track: track, to: playlist)
                }
                vc.title = "SelectPlaylist"
                self?.present(NavigationController.init(rootViewController: vc), animated: true, completion: nil)
            }
        }))
        present(actionSheet, animated: true)
    }

    private func fetchArtistTopTracksData(artistID: String) {
        APICaller.shared.getArtistTopTracksData(for: artistID) { [weak self] result in
            switch result {
            case let .success(model):
                self?.tracks = model
                self?.viewModels = model.compactMap({ track in
                    PlaylistCellViewModel(name: track.name, artistName: track.artists?.first?.name ?? "", artworkURL: URL(string: track.album?.images?.first?.url ?? ""))
                })
                self?.headerViewModel = PlaylistHeaderViewViewModel(name: model.first?.artists?.first?.name, ownerName: "", description: "", artworkURL: URL(string: model.first?.album?.images?.first?.url ?? ""))
                DispatchQueue.main.async {
                    self?.title = self?.tracks.first?.artists?.first?.name
                    self?.collectionView.reloadData()
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchArtistTopTracksData(artistID: artistID)
                }) else { return }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func add(track: AudioTrack, to playlist: Playlist) {
        APICaller.shared.addTrackToPlaylists(track: track, playlist: playlist) { [weak self] result in
            switch result {
            case .success:
                let alert = UIAlertController(title: "", message: "Added \(track.name) to \(playlist.name)", preferredStyle: .alert)
                DispatchQueue.main.async {
                    HapticsManager.shared.vibrate(for: .success)
                    self?.present(alert, animated: true, completion: { [weak self] in
                        UIView.animate(withDuration: 0.1, delay: 0.3, options: .init()) {} completion: { finished in
                            alert.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.add(track: track, to: playlist)
                }) else { return }
                DispatchQueue.main.async {
                    HapticsManager.shared.vibrate(for: .error)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ArtistViewController: UICollectionViewDataSource {
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

extension ArtistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

extension ArtistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(
            from: self,
            tracks: tracks
        )
    }
}
