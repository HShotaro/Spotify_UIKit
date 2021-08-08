//
//  SearchResultSubtitleTableViewCell.swift
//  Music2
//
//  Created by 平野翔太郎 on 2021/08/08.
//

import UIKit

class SearchResultSubtitleTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchResultSubtitleTableViewCell.self)
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 10, y: 0, width: contentView.width - 20, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with title: String) {
        label.text = title
    }
}
