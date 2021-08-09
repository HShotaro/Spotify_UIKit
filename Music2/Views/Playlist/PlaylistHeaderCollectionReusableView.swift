//
//  PlaylistHeaderCollectionReusableView.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = String(describing: PlaylistHeaderCollectionReusableView.self)
    
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.image = UIImage(systemName: "photo")
        return v
    }()
    
    private let playAllButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(playAllButton)
        playAllButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapAll() {
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = height/2
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom+10, width: width-20, height: 70)
        playAllButton.frame = CGRect(x: width-75, y: height-75, width: 60, height: 60)
    }
    
    func configure(with viewModel: PlaylistHeaderViewViewModel?) {
        nameLabel.text = viewModel?.name
        imageView.sd_setImage(with: viewModel?.artworkURL, completed: nil)
    }
}
