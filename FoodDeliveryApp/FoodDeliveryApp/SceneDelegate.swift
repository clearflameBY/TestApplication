//
//  SceneDelegate.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        print("SceneDelegate: willConnectTo called with windowScene.")
        
        // Инициализируем window с текущей сценой
        let newWindow = UIWindow(windowScene: windowScene)
        self.window = newWindow // Присваиваем window свойству self.window для его удержания

        // Проверяем, вошел ли пользователь (для фиктивной авторизации)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        if isLoggedIn {
            // Если вошел, переходим сразу на главный экран
            let mainVC = MainViewController()
            newWindow.rootViewController = UINavigationController(rootViewController: mainVC)
            print("SceneDelegate: Пользователь вошел, устанавливаем MainViewController как root.")
        } else {
            // В противном случае, показываем экран входа
            let loginVC = LoginViewController()
            newWindow.rootViewController = UINavigationController(rootViewController: loginVC)
            print("SceneDelegate: Пользователь НЕ вошел, устанавливаем LoginViewController как root.")
        }

        newWindow.makeKeyAndVisible()
        print("SceneDelegate: Окно сделано ключевым и видимым.")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("SceneDelegate: sceneDidDisconnect called.")
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("SceneDelegate: sceneDidBecomeActive called.")
    }
    func sceneWillResignActive(_ scene: UIScene) {
        print("SceneDelegate: sceneWillResignActive called.")
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("SceneDelegate: sceneWillEnterForeground called.")
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("SceneDelegate: sceneDidEnterBackground called.")
    }
}
