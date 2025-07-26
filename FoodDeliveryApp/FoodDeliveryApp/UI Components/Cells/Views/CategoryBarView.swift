//
//  CategoryBarView.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

protocol CategoryBarViewDelegate: AnyObject {
    func didSelectCategory(at index: Int)
}

class CategoryBarView: UIView {
    weak var delegate: CategoryBarViewDelegate?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // Dynamic width based on content
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .white
        cv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cv.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        return cv
    }()

    private var categoryNames: [String] = []
    private var selectedIndexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(collectionView)
        collectionView.fillSuperview()
    }

    func configure(with names: [String]) {
        self.categoryNames = names
        self.collectionView.reloadData()
        
        // Select the first category by default
        if !names.isEmpty {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: [])
            selectedIndexPath = firstIndexPath
        }
    }
    
    func selectCategory(at index: Int, animated: Bool) {
        guard index < categoryNames.count else { return }
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
        selectedIndexPath = indexPath
    }
}

// MARK: - UICollectionViewDataSource for CategoryBarView
extension CategoryBarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as! CategoryCell
        cell.configure(with: categoryNames[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate for CategoryBarView
extension CategoryBarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        delegate?.didSelectCategory(at: indexPath.item)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Ensure the correct cell is marked as selected when scrolling
        if indexPath == selectedIndexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}
