//
//  CategoryCell.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? .primaryRed : .darkGrayText
            backgroundColor = isSelected ? UIColor.primaryRed.withAlphaComponent(0.1) : .lightGrayBackground
            layer.borderColor = isSelected ? UIColor.primaryRed.cgColor : UIColor.clear.cgColor
            layer.borderWidth = isSelected ? 1.0 : 0.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.fillSuperview(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        
        layer.cornerRadius = 18
        clipsToBounds = true
        backgroundColor = .lightGrayBackground
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}
