//
//  MealCell.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

class MealCell: UITableViewCell {
    static let reuseIdentifier = "MealCell"

    private let mealImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .lightGray
        return iv
    }()

    private let mealNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkGrayText
        label.numberOfLines = 2
        return label
    }()

    private let mealDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        label.text = "Краткое описание блюда, состав и особенности приготовления." // Placeholder description
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGrayText
        label.text = "от 345 ₽" // Placeholder price
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(.primaryRed, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.borderColor = UIColor.primaryRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 6
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubviews(mealImageView, mealNameLabel, mealDescriptionLabel, priceLabel, addButton)
        
        // Add a separator view at the bottom
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            mealImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mealImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mealImageView.widthAnchor.constraint(equalToConstant: 100),
            mealImageView.heightAnchor.constraint(equalToConstant: 100),

            mealNameLabel.topAnchor.constraint(equalTo: mealImageView.topAnchor),
            mealNameLabel.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 16),
            mealNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            mealDescriptionLabel.topAnchor.constraint(equalTo: mealNameLabel.bottomAnchor, constant: 4),
            mealDescriptionLabel.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 16),
            mealDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            priceLabel.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 16),
            priceLabel.bottomAnchor.constraint(equalTo: mealImageView.bottomAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: mealImageView.bottomAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 90),
            addButton.heightAnchor.constraint(equalToConstant: 32),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    func configure(with meal: Meal) {
        mealNameLabel.text = meal.name
        mealImageView.loadImage(from: meal.thumbnail)
    }
}
