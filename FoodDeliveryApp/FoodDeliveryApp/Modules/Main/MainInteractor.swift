//
//  MainInteractor.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

protocol MainBusinessLogic {
    func fetchContent(request: Main.FetchContent.Request)
}

protocol MainDataStore {
    var categories: [Category]? { get }
    var mealsByCategory: [String: [Meal]]? { get }
}

class MainInteractor: MainBusinessLogic, MainDataStore {
    var presenter: MainPresentationLogic?
    var worker: MainWorker?

    var categories: [Category]?
    var mealsByCategory: [String: [Meal]]?

    // MARK: Fetch Content

    func fetchContent(request: Main.FetchContent.Request) {
        worker = MainWorker()

        // Try to load from cache first for offline mode
        if let cachedCategoriesData = UserDefaults.standard.data(forKey: Constants.categoriesCacheKey),
           let cachedMealsData = UserDefaults.standard.data(forKey: Constants.mealsCacheKey) {
            do {
                let decodedCategories = try JSONDecoder().decode(CategoriesResponse.self, from: cachedCategoriesData)
                self.categories = decodedCategories.categories.map { Category(id: $0.idCategory, name: $0.strCategory, thumbnail: $0.strCategoryThumb, description: $0.strCategoryDescription) }

                let decodedMeals = try JSONDecoder().decode([String: MealsResponse].self, from: cachedMealsData)
                self.mealsByCategory = decodedMeals.mapValues { mealsResponse in
                    mealsResponse.meals?.map { Meal(id: $0.idMeal, name: $0.strMeal, thumbnail: $0.strMealThumb) } ?? []
                }

                if let categories = self.categories, let mealsByCategory = self.mealsByCategory {
                    let response = Main.FetchContent.Response(categories: categories, mealsByCategory: mealsByCategory)
                    self.presenter?.presentContent(response: response)
                    print("Loaded data from cache.")
                    return // Data loaded from cache, no need to fetch from network immediately
                }
            } catch {
                print("Failed to decode cached data: \(error)")
            }
        }

        // Fetch from network
        worker?.fetchCategories { [weak self] result in
            switch result {
            case .success(let apiCategories):
                self?.categories = apiCategories.map { Category(id: $0.idCategory, name: $0.strCategory, thumbnail: $0.strCategoryThumb, description: $0.strCategoryDescription) }
                
                // Cache categories
                if let categoriesData = try? JSONEncoder().encode(CategoriesResponse(categories: apiCategories)) {
                    UserDefaults.standard.set(categoriesData, forKey: Constants.categoriesCacheKey)
                }

                self?.fetchMealsForCategories(apiCategories: apiCategories)

            case .failure(let error):
                print("Failed to fetch categories: \(error)")
                // If categories fetch fails and no cached data, present empty state or error
                if self?.categories == nil || self?.categories?.isEmpty == true {
                    let response = Main.FetchContent.Response(categories: [], mealsByCategory: [:])
                    self?.presenter?.presentContent(response: response)
                }
            }
        }
    }

    private func fetchMealsForCategories(apiCategories: [APICategory]) {
        let dispatchGroup = DispatchGroup()
        var fetchedMeals: [String: [APIMeal]] = [:]

        for category in apiCategories {
            dispatchGroup.enter()
            worker?.fetchMeals(forCategory: category.strCategory) { result in
                switch result {
                case .success(let apiMeals):
                    fetchedMeals[category.strCategory] = apiMeals
                case .failure(let error):
                    print("Failed to fetch meals for category \(category.strCategory): \(error)")
                    fetchedMeals[category.strCategory] = [] // Ensure category is present even if no meals
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self, let categories = self.categories else { return }

            self.mealsByCategory = fetchedMeals.mapValues { apiMeals in
                apiMeals.map { Meal(id: $0.idMeal, name: $0.strMeal, thumbnail: $0.strMealThumb) }
            }
            
            // Cache meals
            let mealsResponseDict = fetchedMeals.mapValues { MealsResponse(meals: $0) }
            if let mealsData = try? JSONEncoder().encode(mealsResponseDict) {
                UserDefaults.standard.set(mealsData, forKey: Constants.mealsCacheKey)
            }

            let response = Main.FetchContent.Response(categories: categories, mealsByCategory: self.mealsByCategory!)
            self.presenter?.presentContent(response: response)
        }
    }
}
