//
//  ViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/07/30.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.viewBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings)
        )
        
        fetchData()
    }
    
    private func fetchData() {
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
                    switch result {
                    case let .success(model):
                        print(model)
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
        }
    }

    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }

}

