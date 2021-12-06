//
//  RecommendedTrackCollectionViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: RecommendedTrackCollectionViewCell.self)
    
    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .thin)
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
    
    func configure(with viewModel: RecommendedTrackCellViewModel) {
        artworkImageView.setImageBy(viewModel.artworkURL)
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        artistNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height-30,
                                        width: contentView.width-6,
                                        height: 30
        )
        trackNameLabel.frame = CGRect(x: 3,
                                        y: contentView.height-60,
                                        width: contentView.width-6,
                                        height: 30
        )
        
        let imageSize = contentView.height-70
        artworkImageView.frame = CGRect(
            x: (contentView.width-imageSize)/2,
            y: 3,
            width: imageSize,
            height: imageSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.cancelCurrentLoad()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
}
