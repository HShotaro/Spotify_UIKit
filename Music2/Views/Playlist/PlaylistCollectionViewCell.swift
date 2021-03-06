//
//  PlaylistCollectionViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: PlaylistCollectionViewCell.self)
    
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .thin)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(artworkImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: PlaylistCellViewModel) {
        artworkImageView.setImageBy(viewModel.artworkURL)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = 40
        artworkImageView.frame = CGRect(
            x: 10,
            y: 10,
            width: imageSize,
            height: imageSize
        )
        trackNameLabel.frame = CGRect(x: artworkImageView.right + 5,
                                        y: 10,
                                        width: contentView.width-artworkImageView.right-15,
                                        height: 20
        )
        artistNameLabel.frame = CGRect(x: artworkImageView.right + 5,
                                        y: contentView.height-25,
                                        width: contentView.width-artworkImageView.right-15,
                                        height: 15
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.cancelCurrentLoad()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
}

