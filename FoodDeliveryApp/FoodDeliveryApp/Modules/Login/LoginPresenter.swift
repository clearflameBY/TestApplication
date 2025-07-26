//
//  LoginPresenter.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

protocol LoginPresentationLogic {
    func presentAuthenticationResult(response: Login.Authenticate.Response)
}

class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?

    // MARK: Present Authentication Result

    func presentAuthenticationResult(response: Login.Authenticate.Response) {
        let viewModel = Login.Authenticate.ViewModel(success: response.success, message: response.message)
        viewController?.displayAuthenticationResult(viewModel: viewModel)
    }
}
