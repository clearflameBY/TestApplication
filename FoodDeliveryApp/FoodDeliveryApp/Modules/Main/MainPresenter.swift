//
//  MainPresenter.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

protocol MainPresentationLogic {
    func presentContent(response: Main.FetchContent.Response)
}

class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?

    // MARK: Present Content

    func presentContent(response: Main.FetchContent.Response) {
        var sections: [Main.MenuSection] = []

        for category in response.categories {
            let meals = response.mealsByCategory[category.name] ?? []
            sections.append(Main.MenuSection(category: category, meals: meals))
        }

        let viewModel = Main.FetchContent.ViewModel(categories: response.categories, sections: sections)
        viewController?.displayContent(viewModel: viewModel)
    }
}
