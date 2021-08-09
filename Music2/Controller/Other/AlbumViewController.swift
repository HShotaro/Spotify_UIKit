//
//  AlbumViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

class AlbumViewController: UIViewController {
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
    private let album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var tracks = [AudioTrack]()
    private var viewModels = [AlbumCellViewModel]()
    private var headerViewModel: AlbumHeaderViewViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        collectionView.register(AlbumHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier)
        collectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapActions))
        
        fetchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchData() {
        APICaller.shared.getAlbumDetails(for: album.id) { [weak self] result in
            switch result {
            case let .success(model):
                self?.tracks = model.tracks.items
                self?.viewModels = model.tracks.items.compactMap({ audioTracks in
                    AlbumCellViewModel(name: audioTracks.name , artistName: audioTracks.artists?.first?.name ?? "-")
                })
                
                self?.headerViewModel = AlbumHeaderViewViewModel(name: model.name, ownerName: model.artists.first?.name ?? "-", description: "Release Date: \(String.formattedDate(string: self?.album.release_date ?? ""))", artworkURL: URL(string: model.images.first?.url ?? ""))
                DispatchQueue.main.async {
                    self?.title = model.name
                    self?.collectionView.reloadData()
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchData()
                }) else { return }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func saveAlbum() {
        APICaller.shared.saveAlbum(album: album) { [weak self] result in
            switch result {
            case .success:
                NotificationCenter.default.post(name: .MyAlbumDidChangeNotification, object: nil)
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.saveAlbum()
                }) else { return }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func deleteAlbum() {
        APICaller.shared.deleteAlbum(album: album) { [weak self] result in
            switch result {
            case .success:
                NotificationCenter.default.post(name: .MyAlbumDidChangeNotification, object: nil)
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.deleteAlbum()
                }) else { return }
                DispatchQueue.main.async {
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func didTapActions() {
        let actionSheet = UIAlertController(title: album.name, message: "Actions", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Save Album", style: .default, handler: { [weak self] _ in
            self?.saveAlbum()
        }))
        if isOwner {
            actionSheet.addAction(UIAlertAction(title: "Delete Album", style: .destructive, handler: { [weak self] _ in
                self?.deleteAlbum()
            }))
        }
        present(actionSheet, animated: true)
    }
}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionViewCell.identifier, for: indexPath) as? AlbumCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(with: viewModels[indexPath.row])
        cell.backgroundColor = .systemRed
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AlbumHeaderCollectionReusableView.identifier, for: indexPath) as? AlbumHeaderCollectionReusableView else { return UICollectionReusableView() }
        
        header.configure(with: self.headerViewModel)
        header.delegate = self
        return header
    }
}

extension AlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        
        PlaybackPresenter.shared.startPlayback(
            from: self,
            track: track
        )
    }
}

extension AlbumViewController: AlbumHeaderCollectionReusableViewDelegate {
    func AlbumHeaderCollectionReusableViewDidTapPlayAll(_ header: AlbumHeaderCollectionReusableView) {
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap { track in
            var t = track
            t.album = self.album
            return t
        }
        PlaybackPresenter.shared.startPlayback(
            from: self,
            tracks: tracksWithAlbum
        )
    }
}
