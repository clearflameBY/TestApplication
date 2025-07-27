//
//  MainWorker.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

class MainWorker {
    func fetchCategories(completion: @escaping (Result<[APICategory], NetworkError>) -> Void) {
        let url = Constants.baseURL + Constants.categoriesEndpoint
        NetworkManager.shared.request(url: url) { (result: Result<CategoriesResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.categories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchMeals(forCategory categoryName: String, completion: @escaping (Result<[APIMeal], NetworkError>) -> Void) {
        let encodedCategoryName = categoryName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = Constants.baseURL + Constants.filterByCategoryEndpoint + encodedCategoryName
        NetworkManager.shared.request(url: url) { (result: Result<MealsResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response.meals ?? [])) // Return empty array if meals is nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
