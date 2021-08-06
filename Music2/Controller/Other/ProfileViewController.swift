//
//  ProfileViewController.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/05.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    private let tableView: UITableView = {
        let v = UITableView()
        v.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return v
    }()
    
    private var models = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = UIColor.viewBackground
        tableView.dataSource = self
        tableView.delegate = self
        fetchProfile()
        tableView.isHidden = true
        view.addSubview(tableView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func fetchProfile() {
        APICaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(userProfile):
                    self?.updateUI(with: userProfile)
                case let .failure(error):
                    guard let alert = self?.generateAlert(error: error, retryHandler: { [weak self] in
                        self?.fetchProfile()
                    }) else { return }
                    self?.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    private func updateUI(with userProfile: UserProfile) {
        tableView.isHidden = false
        models = [
            "Full Name: \(userProfile.display_name)",
            "Email Adress: \(userProfile.email)",
            "User ID: \(userProfile.id)",
            "Plan: \(userProfile.product)",
        
        ]
        createTableHeader(with: userProfile.images.first?.url)
        tableView.reloadData()
    }
    
    private func createTableHeader(with url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize: CGFloat = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url, completed: nil)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        tableView.tableHeaderView = headerView
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
    
    
}

extension ProfileViewController: UITableViewDelegate {
    
}
