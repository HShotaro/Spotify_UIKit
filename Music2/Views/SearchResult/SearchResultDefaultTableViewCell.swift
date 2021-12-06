//
//  SearchResultDefaultTableViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import UIKit

class SearchResultDefaultTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchResultDefaultTableViewCell.self)
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.frame.height - 10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.width - iconImageView.right-15, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.cancelCurrentLoad()
        label.text = nil
    }
    
    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        label.text = viewModel.title
        iconImageView.setImageBy(viewModel.image)
    }
}
