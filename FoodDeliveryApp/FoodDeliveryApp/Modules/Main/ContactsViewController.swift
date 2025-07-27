//
//  ContactsViewController.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 27.07.25.
//

import UIKit

class ContactsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Контакты" // Заголовок для Navigation Bar
        
        let label = UILabel()
        label.text = "Экран Контакты"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
