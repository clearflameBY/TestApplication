//
//  LoginWorker.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

class LoginWorker {
    // This is a dummy worker for frontend-only authentication
    func authenticate(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        // Simple dummy authentication logic
        if username == "user" && password == "password" {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            completion(true, nil)
        } else {
            completion(false, "Неверное имя пользователя или пароль.")
        }
    }
}
