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
    var sectionModels = [BrowseSectionType]()
    
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
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings)
        )
        configureCollectionView()
        fetchDataByAsyncLet()
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
    
    private func fetchDataByAsyncLet() {
        Task {
            do {
                async let recommendationGenres = APIManager.shared.getRecommendationGenres()
                async let newReleases = APIManager.shared.getNewReleases()
                async let featuredPlayLists = APIManager.shared.getFeaturedPlaylists()
                let genres = try await recommendationGenres.genres.toRandomSet(numberOfElements: 5)
                async let recommendationTracks = APIManager.shared.getRecommendations(genres: genres)
                try await self.configureModels(newAlbums: newReleases.albums.items, playlists: featuredPlayLists.playlists.items, tracks: recommendationTracks.tracks)
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            } catch {
                let alert = self.generateAlert(error: error, retryHandler: { [weak self] in
                    self?.fetchDataByAsyncLet()
                })
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func fetchDataByTaskGroup() {
        Task {
            var newReleases = [NewReleasesCellViewModel]()
            var featuredPlaylists = [FeaturedPlaylistCellViewModel]()
            var recommendationTracks = [RecommendedTrackCellViewModel]()
            do {
                let sectionModels = try await withThrowingTaskGroup(of: BrowseSectionType.self) { group -> [BrowseSectionType] in
                    group.addTask {
                        let newAlbums = try await APIManager.shared.getNewReleases().albums.items
                        return BrowseSectionType.newReleases(viewModels: newAlbums.compactMap({ album in
                            return NewReleasesCellViewModel(name: album.name, artworkURL: URL(string: album.images?.first?.url ?? ""), numberOfTracks: album.total_tracks ?? 0, artistName: album.artists?.first?.name ?? "-")
                        }))
                    }
                    group.addTask {
                        let playlists = try await APIManager.shared.getFeaturedPlaylists().playlists.items
                        return BrowseSectionType.featuredPlaylists(viewModels: playlists.compactMap({ playlist in
                            return FeaturedPlaylistCellViewModel(playlistID: playlist.id, name: playlist.name, artworkURL: URL(string: playlist.images?.first?.url ?? ""), creatorName: playlist.owner?.display_name ?? "")
                        }))
                    }
                    group.addTask {
                        let genres = try await APIManager.shared.getRecommendationGenres().genres.toRandomSet(numberOfElements: 5)
                        let tracks = try await APIManager.shared.getRecommendations(genres: genres).tracks
                        return BrowseSectionType.recommendedTracks(viewModels: tracks.compactMap({ audioTrack in
                            return RecommendedTrackCellViewModel(name: audioTrack.name, artistName: audioTrack.artists?.first?.name ?? "-", artworkURL: URL(string: audioTrack.album?.images?.first?.url ?? ""))
                        }))
                    }
                    
                    for try await sectionModel in group {
                        switch sectionModel {
                        case .newReleases(let viewModels):
                            newReleases = viewModels
                        case .featuredPlaylists(let viewModels):
                            featuredPlaylists = viewModels
                        case .recommendedTracks(let viewModels):
                            recommendationTracks = viewModels
                        }
                    }
                    return [
                        BrowseSectionType.newReleases(viewModels: newReleases),
                        BrowseSectionType.featuredPlaylists(viewModels: featuredPlaylists),
                        BrowseSectionType.recommendedTracks(viewModels: recommendationTracks)
                    ]
                }
                
                self.sectionModels = sectionModels
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            } catch {
                let alert = self.generateAlert(error: error, retryHandler: { [weak self] in
                    self?.fetchDataByTaskGroup()
                })
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func fetchDataByDispatchGroup() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponse?
        var featuredPlayLists: FeaturedPlaylistsResponse?
        var recommendations: RecommendationResponse?
        
        // New Releases
        APIManager.shared.getNewReleases { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case let .success(model):
                newReleases = model
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchDataByDispatchGroup()
                }) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        // Featured Playlists
        APIManager.shared.getFeaturedPlaylists { [weak self] result in
            defer {
                group.leave()
            }
            switch result {
            case let .success(model):
                featuredPlayLists = model
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchDataByDispatchGroup()
                }) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        // Recommended Tracks
        APIManager.shared.getRecommendationGenres { [weak self] result in
            switch result {
            case let .success(model):
                let genres = model.genres.toRandomSet(numberOfElements: 5)
                
                APIManager.shared.getRecommendations(genres: genres) { result in
                    defer {
                        group.leave()
                    }
                    switch result {
                    case let .success(model):
                        recommendations = model
                    case let .failure(error):
                        guard let alert = self?.generateAlert(error: error, retryHandler: {
                            self?.fetchDataByDispatchGroup()
                        }) else { return }
                        DispatchQueue.main.async { [weak self] in
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchDataByDispatchGroup()
                }) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            
            group.notify(queue: .main) {
                guard let albums = newReleases?.albums.items,
                      let playlists = featuredPlayLists?.playlists.items,
                      let tracks = recommendations?.tracks else {
                    return
                }
                
                self?.configureModels(newAlbums: albums, playlists: playlists, tracks: tracks)
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
    
        }
    }
    
    var newAlbums = [Album]()
    var tracks = [AudioTrack]()
    
    private func configureModels(
        newAlbums: [Album],
        playlists: [Playlist],
        tracks: [AudioTrack]
    ) {
        self.newAlbums = newAlbums
        self.tracks = tracks
        self.sectionModels = [
            .newReleases(viewModels: newAlbums.compactMap({ album in
                return NewReleasesCellViewModel(name: album.name, artworkURL: URL(string: album.images?.first?.url ?? ""), numberOfTracks: album.total_tracks ?? 0, artistName: album.artists?.first?.name ?? "-")
            })),
            .featuredPlaylists(viewModels: playlists.compactMap({ playlist in
                return FeaturedPlaylistCellViewModel(playlistID: playlist.id, name: playlist.name, artworkURL: URL(string: playlist.images?.first?.url ?? ""), creatorName: playlist.owner?.display_name ?? "")
            })),
            .recommendedTracks(viewModels: tracks.compactMap({ audioTrack in
                return RecommendedTrackCellViewModel(name: audioTrack.name, artistName: audioTrack.artists?.first?.name ?? "-", artworkURL: URL(string: audioTrack.album?.images?.first?.url ?? ""))
            }))
        ]
    }

    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionModels.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sectionModels[section] {
        case let .newReleases(viewModels):
            return viewModels.count
        case let .featuredPlaylists(viewModels):
            return viewModels.count
        case let .recommendedTracks(viewModels):
            return viewModels.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sectionModels[indexPath.section] {
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
        header.configure(with: sectionModels[indexPath.section].title)
        return header
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        switch sectionModels[indexPath.section] {
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case let .featuredPlaylists(playlists):
            let playlistID = playlists[indexPath.row].playlistID
            let vc = PlaylistViewController(playlistID: playlistID)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
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
