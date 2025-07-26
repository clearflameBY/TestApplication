//
//  LoginViewController.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import UIKit

protocol LoginDisplayLogic: AnyObject {
    func displayAuthenticationResult(viewModel: Login.Authenticate.ViewModel)
}

class LoginViewController: UIViewController, LoginDisplayLogic {
    var interactor: LoginBusinessLogic?
    var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?

    // MARK: UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Вход"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .darkGrayText
        // Понижаем приоритет сжатия по вертикали, чтобы метка могла сжиматься при необходимости
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Имя пользователя"
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.returnKeyType = .next
        tf.backgroundColor = .lightGrayBackground
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Пароль"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .done
        tf.backgroundColor = .lightGrayBackground
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // Изменено: lazy var и addTarget внутри замыкания
    var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryRed
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup Clean Swift objects

    private func setup() {
        let viewController = self
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("LoginViewController: viewDidLoad called.")
        view.backgroundColor = .white
        
        setupUI() // Вызываем метод настройки UI
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: UI Setup

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, usernameTextField, passwordTextField, loginButton, errorMessageLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)

        let bottomConstraint = stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        bottomConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            bottomConstraint,
            
            usernameTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            passwordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            loginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }

    // MARK: Actions

    @objc func handleLogin() {
        print("LoginViewController: handleLogin called.")
        errorMessageLabel.isHidden = true
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorMessageLabel.text = "Пожалуйста, введите имя пользователя и пароль."
            errorMessageLabel.isHidden = false
            return
        }

        let request = Login.Authenticate.Request(username: username, password: password)
        interactor?.authenticateUser(request: request)
    }

    // MARK: Display Logic

    func displayAuthenticationResult(viewModel: Login.Authenticate.ViewModel) {
        DispatchQueue.main.async {
            if viewModel.success {
                self.router?.routeToMain()
            } else {
                self.errorMessageLabel.text = viewModel.message
                self.errorMessageLabel.isHidden = false
            }
        }
    }
}
