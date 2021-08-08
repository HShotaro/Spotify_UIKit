//
//  CategoryViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import UIKit

class CategoryViewController: UIViewController {
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0 / 2)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            
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

            let section = NSCollectionLayoutSection(group: verticalGroup)
            return section
        })
    )
    
    private var viewModels = [FeaturedPlaylistCellViewModel]()
    let categoryID: String
    
    init(categoryID: String, title: String) {
        self.categoryID = categoryID
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        collectionView.backgroundColor = UIColor.viewBackground
        view.addSubview(collectionView)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
       fetchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = view.bounds
    }

    
    var playlistIDs = [String]()
    private func fetchData() {
        APICaller.shared.getCategoryPlayList(categoryID: categoryID) { [weak self] result in
            switch result {
            case let .success(playlists):
                self?.playlistIDs = playlists.map { $0.id }
                self?.viewModels = playlists.compactMap({ p in
                    FeaturedPlaylistCellViewModel(name: p.name, artworkURL: URL(string: p.images?.first?.url ?? ""), creatorName: p.owner?.display_name ?? "")
                })
                DispatchQueue.main.async {
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

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        let playlist = viewModels[indexPath.row]
        cell.configure(with: CategoryCellViewModel(id: playlistIDs[indexPath.row], name: playlist.name ?? "", iconURL: playlist.artworkURL))
        return cell
    }
}

extension CategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PlaylistViewController(attribute: .playlist(id: playlistIDs[indexPath.row]))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
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
