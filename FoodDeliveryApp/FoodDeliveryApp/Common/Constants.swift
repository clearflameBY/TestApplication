//
//  Constants.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

struct Constants {
    static let baseURL = "https://www.themealdb.com/api/json/v1/1/"
    static let categoriesEndpoint = "categories.php"
    static let filterByCategoryEndpoint = "filter.php?c="
    static let mealsCacheKey = "cachedMealsData"
    static let categoriesCacheKey = "cachedCategoriesData"
}
