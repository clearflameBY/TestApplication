//
//  LoginModels.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

enum Login {
    // MARK: Use cases

    enum Authenticate {
        struct Request {
            let username: String
            let password: String
        }
        struct Response {
            let success: Bool
            let message: String?
        }
        struct ViewModel {
            let success: Bool
            let message: String?
        }
    }
}
