//
//  ViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/07/30.
//

import UIKit

class HomeViewController: UIViewController {
    enum BrowseSectionType {
        case newReleases(viewModels: [NewReleasesCellViewModel])
        case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])
        case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
        
        var title: String {
            switch self {
            case .newReleases:
                return "New Released Albums"
            case .featuredPlaylists:
                return "Featured Playlists"
            case .recommendedTracks:
                return "Recommended Tracks"
            }
        }
    }
    var sections = [BrowseSectionType]()
    
    private var collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection in
        return HomeViewController.createSectionLayout(section: section)
    })
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings)
        )
        configureCollectionView()
        fetchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureCollectionView() {
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.viewBackground
    }
    
    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top
            )
        ]
        
        switch section {
        case 0:
            //MARK: newReleases Section
            
            // Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            // Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)),
                subitem: item,
                count: 3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 1:
            //MARK: featuredPlaylists
            // Item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            // Group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)),
                subitem: item,
                count: 2
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)),
                subitem: verticalGroup,
                count: 1
            )
            // Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 2:
            //MARK: recommendedTracks
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
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            return NSCollectionLayoutSection.init(group: NSCollectionLayoutGroup.init(layoutSize: NSCollectionLayoutSize.init(widthDimension: .absolute(.zero), heightDimension: .absolute(.zero))))
        }
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlayLists: FeaturedPlaylistsResponse?
        var recommendations: RecommendationResponse?
        
        // New Releases
        APICaller.shared.getNewReleases { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case let .success(model):
                newReleases = model
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchData()
                }) else { return }
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
        // Featured Playlists
        APICaller.shared.getFeaturedPlaylists { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case let .success(model):
                featuredPlayLists = model
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchData()
                }) else { return }
                self?.present(alert, animated: true, completion: nil)
            }
        }
        // Recommended Tracks
        APICaller.shared.getRecommendationGenres { [weak self] result in
            switch result {
            case let .success(model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APICaller.shared.getRecommendations(genres: seeds) { result in
                    defer {
                        group.leave()
                    }
                    switch result {
                    case let .success(model):
                        recommendations = model
                    case let .failure(error):
                        guard let alert = self?.generateAlert(error: error, retryHandler: {
                            self?.fetchData()
                        }) else { return }
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchData()
                }) else { return }
                self?.present(alert, animated: true, completion: nil)
            }
            
            group.notify(queue: .main) {
                guard let albums = newReleases?.albums.items,
                      let playlists = featuredPlayLists?.playlists.items,
                      let tracks = recommendations?.tracks else {
                    return
                }
                
                self?.configureModels(newAlbums: albums, playlists: playlists, tracks: tracks)
            }
    
        }
    }
    
    var newAlbumIDs = [String]()
    var playlistIDs = [String]()
    var tracks = [AudioTrack]()
    
    private func configureModels(
        newAlbums: [Album],
        playlists: [Playlist],
        tracks: [AudioTrack]
    ) {
        self.newAlbumIDs = newAlbums.map { $0.id }
        self.playlistIDs = playlists.map { $0.id }
        self.tracks = tracks
        self.sections = [
            .newReleases(viewModels: newAlbums.compactMap({ album in
                return NewReleasesCellViewModel(name: album.name, artworkURL: URL(string: album.images.first?.url ?? ""), numberOfTracks: album.total_tracks, artistName: album.artists.first?.name ?? "-")
            })),
            .featuredPlaylists(viewModels: playlists.compactMap({ playlist in
                return FeaturedPlaylistCellViewModel(name: playlist.name, artworkURL: URL(string: playlist.images.first?.url ?? ""), creatorName: playlist.owner.display_name)
            })),
            .recommendedTracks(viewModels: tracks.compactMap({ audioTrack in
                return RecommendedTrackCellViewModel(name: audioTrack.name, artistName: audioTrack.artists.first?.name ?? "-", artworkURL: URL(string: audioTrack.album?.images.first?.url ?? ""))
            }))
        ]
        
        collectionView.reloadData()
    }

    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case let .newReleases(viewModels):
            return viewModels.count
        case let .featuredPlaylists(viewModels):
            return viewModels.count
        case let .recommendedTracks(viewModels):
            return viewModels.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case let .newReleases(viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else { return UICollectionViewCell() }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case let .featuredPlaylists(viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else { return UICollectionViewCell() }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case let .recommendedTracks(viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else { return UICollectionViewCell() }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        header.configure(with: sections[indexPath.section].title)
        return header
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .newReleases:
            let albumID = newAlbumIDs[indexPath.row]
            let vc = AlbumViewController(albumID: albumID)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .featuredPlaylists:
            let playlistID = playlistIDs[indexPath.row]
            let vc = PlaylistViewController(playlistID: playlistID)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveLinear, animations: {
                    cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: nil)
            }
        }
}
