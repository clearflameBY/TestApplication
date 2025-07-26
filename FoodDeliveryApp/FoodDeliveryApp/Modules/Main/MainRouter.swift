//
//  MainRouter.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

@objc protocol MainRoutingLogic {
    // func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol MainDataPassing {
    var dataStore: MainDataStore? { get }
}

class MainRouter: NSObject, MainRoutingLogic, MainDataPassing {
    weak var viewController: MainViewController?
    var dataStore: MainDataStore?

    // MARK: Routing

    // func routeToSomewhere(segue: UIStoryboardSegue?) {
    //   if let segue = segue {
    //     let destinationVC = segue.destination as! SomewhereViewController
    //     var destinationDS = destinationVC.router!.dataStore!
    //     passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //   } else {
    //     let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //     let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //     var destinationDS = destinationVC.router!.dataStore!
    //     passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //     navigateToSomewhere(source: viewController!, destination: destinationVC)
    //   }
    // }

    // MARK: Navigation
    // Этот метод был удален, так как он должен быть только в LoginRouter.
    // func navigateToMain(source: LoginViewController, destination: MainViewController) {
    //     source.navigationController?.pushViewController(destination, animated: true)
    // }
}
