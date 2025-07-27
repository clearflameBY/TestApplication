//
//  CartViewController.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 27.07.25.
//

import UIKit

class CartViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Корзина" // Заголовок для Navigation Bar

        let label = UILabel()
        label.text = "Экран Корзина"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
