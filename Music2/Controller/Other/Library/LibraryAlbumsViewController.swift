//
//  LibraryAlbumViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/09.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {
    
    var albumlist = [Album]()
    
    var selectionHandler: ((Album) -> Void)?
    
    private let tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .grouped)
        v.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        return v
    }()
    
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
        
        observer = NotificationCenter.default.addObserver(forName: .MyAlbumDidChangeNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchData()
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    

    private func fetchData() {
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            switch result {
            case let .success(albumlist):
                self?.albumlist = albumlist
                DispatchQueue.main.async { [weak self] in
                    self?.updateUI()
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
    

    private func updateUI() {
        tableView.reloadData()
    }
}

extension LibraryAlbumsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
        let album = albumlist[indexPath.row]
        cell.configure(with: SearchResultDefaultTableViewCellViewModel(title: album.name, image: URL(string: album.images?.first?.url ?? "")))
        return cell
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectionHandler == nil else {
            selectionHandler?(albumlist[indexPath.row])
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albumlist[indexPath.row]
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
