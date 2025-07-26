//
//  LoginRouter.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

@objc protocol LoginRoutingLogic {
    func routeToMain()
}

protocol LoginDataPassing {
    var dataStore: LoginDataStore? { get }
}

class LoginRouter: NSObject, LoginRoutingLogic, LoginDataPassing {
    weak var viewController: LoginViewController?
    var dataStore: LoginDataStore?

    // MARK: Routing

    func routeToMain() {
        let destinationVC = MainViewController()
        navigateToMain(source: viewController!, destination: destinationVC)
    }

    // MARK: Navigation

    func navigateToMain(source: LoginViewController, destination: MainViewController) {
        source.navigationController?.pushViewController(destination, animated: true)
    }
}
