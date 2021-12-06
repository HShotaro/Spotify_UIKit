//
//  CategoryCollectionViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: CategoryCollectionViewCell.self)
    
    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.tintColor = .white
        v.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        v.alpha = 0.4
        return v
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemOrange,
        .systemGreen,
        .systemRed,
        .systemYellow,
        .darkGray,
        .systemTeal
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.cancelCurrentLoad()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: contentView.height-60, width: contentView.width-20, height: 60)
        imageView.frame = contentView.frame
    }
    
    func configure(with category: CategoryCellViewModel) {
        label.text = category.name
        imageView.setImageBy(category.iconURL)
        contentView.backgroundColor = colors.randomElement()
    }
}
