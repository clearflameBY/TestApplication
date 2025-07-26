//
//  MainModels.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

// MARK: - API Models
// Changed to Codable for both encoding and decoding
struct CategoriesResponse: Codable {
    let categories: [APICategory]
}

// Changed to Codable for both encoding and decoding
struct APICategory: Codable {
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
}

// Changed to Codable for both encoding and decoding
struct MealsResponse: Codable {
    let meals: [APIMeal]? // Can be nil if no meals found for a category
}

// Changed to Codable for both encoding and decoding
struct APIMeal: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
}

// MARK: - App Models (for internal use, can be same as API models if no transformation needed)
struct Category {
    let id: String
    let name: String
    let thumbnail: String
    let description: String
}

struct Meal {
    let id: String
    let name: String
    let thumbnail: String
}

enum Main {
    // MARK: Use cases

    enum FetchContent {
        struct Request {}
        struct Response {
            let categories: [Category]
            let mealsByCategory: [String: [Meal]] // Category Name: [Meals]
        }
        struct ViewModel {
            let categories: [Category]
            let sections: [MenuSection]
        }
    }

    struct MenuSection {
        let category: Category
        let meals: [Meal]
    }
}
