//
//  FeaturedPlaylistCollectionViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: FeaturedPlaylistCollectionViewCell.self)
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel) {
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height-30,
                                        width: contentView.width-6,
                                        height: 30
        )
        playlistNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height-60,
                                        width: contentView.width-6,
                                        height: 30
        )
        
        let imageSize = contentView.height-70
        playlistCoverImageView.frame = CGRect(
            x: (contentView.width-imageSize)/2,
            y: 3,
            width: imageSize,
            height: imageSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistCoverImageView.image = UIImage(systemName: "photo")
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
    }
}
