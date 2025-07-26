//
//  LoginInteractor.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

protocol LoginBusinessLogic {
    func authenticateUser(request: Login.Authenticate.Request)
}

protocol LoginDataStore {
    // var name: String { get set }
}

class LoginInteractor: LoginBusinessLogic, LoginDataStore {
    var presenter: LoginPresentationLogic?
    var worker: LoginWorker?

    // MARK: Authenticate User

    func authenticateUser(request: Login.Authenticate.Request) {
        worker = LoginWorker()
        worker?.authenticate(username: request.username, password: request.password) { [weak self] success, message in
            let response = Login.Authenticate.Response(success: success, message: message)
            self?.presenter?.presentAuthenticationResult(response: response)
        }
    }
}
