//
//  AlbumCollectionViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/07.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: AlbumCollectionViewCell.self)
    
    private let nameLabel: UILabel = {
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
        contentView.addSubview(nameLabel)
        contentView.addSubview(artistNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: AlbumCellViewModel) {
        nameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 5,
                                        y: 10,
                                        width: contentView.width-10,
                                        height: 20
        )
        artistNameLabel.frame = CGRect(x: 5,
                                        y: contentView.height-25,
                                        width: contentView.width-10,
                                        height: 15
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        artistNameLabel.text = nil
    }
}


