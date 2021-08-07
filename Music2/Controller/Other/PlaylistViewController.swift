//
//  PlaylistViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

class PlaylistViewController: UIViewController {
    private let playlistID: String
    
    private let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout.init(sectionProvider: { _, _ in
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0 / 2)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        // Group
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0 / 2)),
            subitem: item,
            count: 2
        )
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0 / 2)),
            subitem: horizontalGroup,
            count: 1
        )
        // Section
        let section = NSCollectionLayoutSection(group: verticalGroup)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize.init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        return section
    }))
    
    init(playlistID: String) {
        self.playlistID = playlistID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var headerViewModel: PlaylistHeaderViewViewModel?
    private var shareViewModel: (urlString: String, title: String)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        fetchData()
    }
    
    @objc private func didTapShare() {
        guard let shareViewModel = shareViewModel, let url = URL(string: shareViewModel.urlString) else {
            return
        }
        let vc = UIActivityViewController(activityItems: [shareViewModel.title, url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func fetchData() {
        APICaller.shared.getPlaylistDetails(for: playlistID) { [weak self] result in
            switch result {
            case let .success(model):
                self?.viewModels = model.tracks.items.compactMap({ playList in
                    RecommendedTrackCellViewModel(name: playList.track.name, artistName: playList.track.artists.first?.name ?? "", artworkURL: URL(string: playList.track.album?.images.first?.url ?? ""))
                })
                
                self?.headerViewModel = PlaylistHeaderViewViewModel(name: model.name, ownerName: model.tracks.items.first?.track.artists.first?.name ?? "", description: model.description, artworkURL: URL(string: model.images.first?.url ?? ""))
                self?.shareViewModel = (urlString: model.external_urls["spotify"] as? String ?? "", title: model.description)
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
}

extension PlaylistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else { return UICollectionViewCell() }
        cell.backgroundColor = .systemRed
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
        // Play Song
    }
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        // Start play list play in queue
    }
}
