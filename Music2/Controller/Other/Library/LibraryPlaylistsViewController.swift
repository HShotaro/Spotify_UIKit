//
//  LibraryPlaylistViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/09.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {

    var playlists = [Playlist]()
    
    private let noPlaylistView = ActionLabelView()
    
    private let tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .grouped)
        v.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        v.isHidden = true
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        setUpNoPlaylistView()
        fetchData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
        noPlaylistView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistView.center = view.center
    }
    

    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            switch result {
            case let .success(playlists):
                self?.playlists = playlists
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
    
    func showCreatePlaylistAlert() {
        let alert = UIAlertController(
            title: "New Playlists",
            message: "Enter playlist name",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Playlist ... "
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            APICaller.shared.createPlaylists(with: text) { [weak self] result in
                switch result {
                case .success:
                    self?.fetchData()
                case let .failure(error):
                    guard let alert = self?.generateAlert(error: error, retryHandler: {
                        self?.fetchData()
                    }) else { return }
                    DispatchQueue.main.async {
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setUpNoPlaylistView() {
        view.addSubview(noPlaylistView)
        noPlaylistView.delegate = self
        noPlaylistView.configure(with: ActionLabelViewViewModel(text: "You don't have anuy playlist yet", actionTitle: "Create"))
    }

    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistView.isHidden = false
            tableView.isHidden = true
        } else {
            noPlaylistView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else { return UITableViewCell() }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultDefaultTableViewCellViewModel(title: playlist.name, image: URL(string: playlist.images?.first?.url ?? "")))
        return cell
    }
}

extension LibraryPlaylistsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        let vc = PlaylistViewController(attribute: .playlist(id: playlist.id))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
