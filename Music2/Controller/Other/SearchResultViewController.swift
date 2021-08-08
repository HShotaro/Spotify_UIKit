//
//  SearchResultViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func didSelectResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController {
    weak var delegate: SearchResultViewControllerDelegate?
    struct Section {
        let title: String
        let results: [SearchResult]
    }
    
    
    private var sections: [Section] = []
    
    private let tableView: UITableView = {
        let v = UITableView()
        v.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        v.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        v.backgroundColor = .systemBackground
        v.isHidden = true
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    

    func update(with results : [SearchResult]) {
        let artists = results.filter {
            switch $0 {
            case .artist: return true
            default:return false
            }
        }
        
        let albums = results.filter {
            switch $0 {
            case .album: return true
            default: return false
            }
        }
        
        let tracks = results.filter {
            switch $0 {
            case .track: return true
            default: return false
            }
        }
        
        let playlists = results.filter {
            switch $0 {
            case .playlist: return true
            default: return false
            }
        }
        self.sections =
            (artists.count > 0 ? [Section(title: "Artists", results: artists)] : []) +
            (albums.count > 0 ? [Section(title: "Albums", results: albums)] : []) +
            (tracks.count > 0 ? [Section(title: "Tracks", results: tracks)] : []) +
            (playlists.count > 0 ? [Section(title: "Playlists", results: playlists)] : [])
        
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }

}

extension SearchResultViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        switch result {
        case let .artist(artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultDefaultTableViewCellViewModel(title: artist.name, image: URL(string: artist.images?.first?.url ?? "")))
            return cell
        case let .album(album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultDefaultTableViewCellViewModel(title: album.name, image: URL(string: album.images?.first?.url ?? "")))
            return cell
        case let .track(track):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell() }
            cell.configure(with: track.name)
            return cell
        case let .playlist(playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
            cell.configure(with: SearchResultDefaultTableViewCellViewModel(title: playlist.name, image: URL(string: playlist.images?.first?.url ?? "")))
            return cell
        }
    }
    
    
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.didSelectResult(sections[indexPath.section].results[indexPath.row])
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
