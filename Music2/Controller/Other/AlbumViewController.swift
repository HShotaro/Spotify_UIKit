//
//  AlbumViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

class AlbumViewController: UIViewController {
    private let albumID: String
    
    init(albumID: String) {
        self.albumID = albumID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        
        fetchData()
    }
    
    private func fetchData() {
        APICaller.shared.getAlbumDetails(for: albumID) { [weak self] result in
            switch result {
            case let .success(model):
                break
            case let .failure(error):
                guard let alert = self?.generateAlert(error: error, retryHandler: {
                    self?.fetchData()
                }) else { return }
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
