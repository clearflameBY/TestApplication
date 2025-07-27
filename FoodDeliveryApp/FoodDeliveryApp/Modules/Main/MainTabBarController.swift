//
//  MainTabBarController.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 27.07.25.
//
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupAppearance()
    }
    
    private func setupTabBar() {
        // Создаем экземпляры View Controller'ов для каждой вкладки
        let menuVC = MainViewController()
        let contactsVC = ContactsViewController()
        let profileVC = ProfileViewController()
        let cartVC = CartViewController()
        
        // Встраиваем их в UINavigationController, если нужна навигация внутри вкладки
        let menuNavController = UINavigationController(rootViewController: menuVC)
        let contactsNavController = UINavigationController(rootViewController: contactsVC)
        let profileNavController = UINavigationController(rootViewController: profileVC)
        let cartNavController = UINavigationController(rootViewController: cartVC)
        
        // Настраиваем Tab Bar Item для каждой вкладки
        menuNavController.tabBarItem = UITabBarItem(title: "Меню", image: UIImage(systemName: "fork.knife.circle.fill"), tag: 0)
        contactsNavController.tabBarItem = UITabBarItem(title: "Контакты", image: UIImage(systemName: "phone.fill"), tag: 1)
        profileNavController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.fill"), tag: 2)
        cartNavController.tabBarItem = UITabBarItem(title: "Корзина", image: UIImage(systemName: "bag.fill"), tag: 3)
        
        // Устанавливаем View Controllers для Tab Bar Controller
        viewControllers = [menuNavController, contactsNavController, profileNavController, cartNavController]
    }
    
    private func setupAppearance() {
        // Настройка внешнего вида Tab Bar
        tabBar.tintColor = .primaryRed // Цвет выбранной иконки/текста
        tabBar.unselectedItemTintColor = .gray // Цвет невыбранной иконки/текста
        tabBar.backgroundColor = .white // Фон Tab Bar
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor // Тонкая граница сверху
        tabBar.clipsToBounds = true // Обрезаем содержимое по границам
    }
}
