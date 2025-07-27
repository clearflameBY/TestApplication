//
//  MainViewController.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//
import UIKit

protocol MainDisplayLogic: AnyObject {
    func displayContent(viewModel: Main.FetchContent.ViewModel)
}

class MainViewController: UIViewController, MainDisplayLogic {
    var interactor: MainBusinessLogic?
    var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing)?

    private var categories: [Category] = []
    private var menuSections: [Main.MenuSection] = []

    private var initialCategoryBarY: CGFloat = 0
    private let categoryBarHeight: CGFloat = 60
    
    // Метка для отображения текущего города
    private let currentCityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium) // SF Pro Display Medium 17pt
        label.textColor = .darkGrayText
        label.text = "Минск" // Начальное значение
        return label
    }()

    // MARK: UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(BannerCell.self, forCellReuseIdentifier: BannerCell.reuseIdentifier)
        tableView.register(MenuSectionHeader.self, forHeaderFooterViewReuseIdentifier: MenuSectionHeader.reuseIdentifier)
        tableView.register(MealCell.self, forCellReuseIdentifier: MealCell.reuseIdentifier)
        tableView.insetsContentViewsToSafeArea = false // Allows content to go under safe area if needed
        return tableView
    }()

    private lazy var categoryBar: CategoryBarView = {
        let bar = CategoryBarView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.delegate = self
        return bar
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        let router = MainRouter()
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
        view.backgroundColor = .white // Белый фон
        setupUI()
        interactor?.fetchContent(request: Main.FetchContent.Request())
        activityIndicator.startAnimating()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Calculate initial Y position of the category bar after layout
        if initialCategoryBarY == 0 {
            if let bannerCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                initialCategoryBarY = bannerCell.frame.maxY
            }
        }
    }

    // MARK: UI Setup

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(categoryBar)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), // ИСПРАВЛЕНО: Привязка к safeAreaLayoutGuide.bottomAnchor

            categoryBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryBar.heightAnchor.constraint(equalToConstant: categoryBarHeight),
            // Initial position will be set in scrollViewDidScroll or viewDidLayoutSubviews
            // It will be positioned below the banners initially
            categoryBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200), // Placeholder, will be adjusted

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        // Кнопка для выбора города
        let cityButton = UIButton(type: .system)
        cityButton.tintColor = .darkGrayText
        cityButton.setTitleColor(.darkGrayText, for: .normal)
        cityButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cityButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        cityButton.semanticContentAttribute = .forceLeftToRight // Иконка слева от текста
        cityButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2) // Небольшой отступ
        cityButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // Убрать лишние отступы
        
        // Создаем меню для кнопки города
        let cities = ["Минск", "Гомель", "Могилёв", "Гродно"]
        let menuActions = cities.map { city in
            UIAction(title: city) { [weak self] _ in
                self?.citySelected(city)
            }
        }
        cityButton.menu = UIMenu(title: "", children: menuActions)
        cityButton.showsMenuAsPrimaryAction = true // Показывает меню при нажатии
        
        // Устанавливаем текущий город на кнопке
        cityButton.setTitle(currentCityLabel.text, for: .normal)
        
        // Создаем UIBarButtonItem из кнопки
        let cityBarButtonItem = UIBarButtonItem(customView: cityButton)
        self.navigationItem.leftBarButtonItem = cityBarButtonItem

        // Элемент для правой части (иконка профиля)
        let profileIcon = UIImageView(image: UIImage(systemName: "person.circle.fill")) // Иконка профиля
        profileIcon.tintColor = .gray// Или другой цвет по Figma
        profileIcon.contentMode = .scaleAspectFit
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        profileIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let profileBarButtonItem = UIBarButtonItem(customView: profileIcon)
        self.navigationItem.rightBarButtonItem = profileBarButtonItem
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = .white // Фон навигационной панели белый
        navigationController?.navigationBar.shadowImage = UIImage() // Убираем тень
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // MARK: City Selection Handler
    @objc private func citySelected(_ city: String) {
        currentCityLabel.text = city
        // Обновляем текст на кнопке после выбора
        if let cityButton = self.navigationItem.leftBarButtonItem?.customView as? UIButton {
            cityButton.setTitle(city, for: .normal)
        }
        print("Выбран город: \(city)")
        // Здесь можно добавить логику для обновления данных в зависимости от города
    }

    // MARK: Display Logic

    func displayContent(viewModel: Main.FetchContent.ViewModel) {
        DispatchQueue.main.async {
            self.categories = viewModel.categories
            self.menuSections = viewModel.sections
            self.categoryBar.configure(with: viewModel.categories.map { $0.name })
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            
            // Adjust initial category bar position after data loads and table reloads
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            if let bannerCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                self.initialCategoryBarY = bannerCell.frame.maxY
                self.categoryBar.frame.origin.y = self.initialCategoryBarY - self.tableView.contentOffset.y + self.view.safeAreaInsets.top
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + menuSections.count // Banners + Menu Sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Banner cell
        } else {
            let menuSectionIndex = section - 1
            return menuSections[menuSectionIndex].meals.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: BannerCell.reuseIdentifier, for: indexPath) as! BannerCell
            // Реальные URL-адреса изображений для баннеров
            cell.configure(with: [
                "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg", // Пример: Chicken Handi
                "https://s0.rbk.ru/v6_top_pics/resized/1200xH/media/img/2/26/756775139431262.webp", // Пример: Big Mac
                "https://www.themealdb.com/images/media/meals/rvypwy1503069308.jpg"  // Пример: Beef Wellington
            ])
            return cell
        } else {
            let menuSectionIndex = indexPath.section - 1
            let meal = menuSections[menuSectionIndex].meals[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: MealCell.reuseIdentifier, for: indexPath) as! MealCell
            cell.configure(with: meal)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200 // Высота для ячейки баннера
        } else {
            return 160 // Увеличена высота для ячейки блюда, чтобы вместить все элементы и отступы
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil // Нет заголовка для секции баннеров
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MenuSectionHeader.reuseIdentifier) as! MenuSectionHeader
            let menuSectionIndex = section - 1
            header.titleLabel.text = menuSections[menuSectionIndex].category.name
            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1 // Минимально возможная высота, чтобы избежать пустого пространства
        } else {
            return 50 // Высота для заголовка секции категории
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTop = view.safeAreaInsets.top
        let scrollOffset = scrollView.contentOffset.y
        
        // Вычисляем целевую Y для панели категорий
        // Она должна прилипать к верхней безопасной области при прокрутке мимо ее исходной позиции
        // initialCategoryBarY - это нижняя граница ячейки баннера
        let stickyY = safeAreaTop
        let currentCategoryBarY = initialCategoryBarY - scrollOffset + safeAreaTop // Скорректировано для безопасной области

        if currentCategoryBarY <= stickyY {
            categoryBar.frame.origin.y = stickyY
        } else {
            categoryBar.frame.origin.y = currentCategoryBarY
        }
    }
}

// MARK: - CategoryBarViewDelegate
extension MainViewController: CategoryBarViewDelegate {
    func didSelectCategory(at index: Int) {
        // Прокрутка к соответствующей секции в табличном представлении
        guard index < menuSections.count else { return }
        
        // Секции меню начинаются с секции 1 в табличном представлении
        let targetSection = index + 1
        
        // Прокрутка к заголовку целевой секции
        let indexPath = IndexPath(row: 0, section: targetSection)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        // Ручная корректировка позиции прокрутки, чтобы панель категорий была видна и прилипала
        // Это немного сложно, потому что `scrollToRow` может не идеально выравнивать
        // Мы хотим, чтобы верхняя часть секции была чуть ниже прилипшей панели категорий
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Небольшая задержка, чтобы прокрутка завершилась
            if self.tableView.headerView(forSection: targetSection) != nil {
                let headerFrameInTableView = self.tableView.rectForHeader(inSection: targetSection)
                _ = headerFrameInTableView.origin.y - self.tableView.contentOffset.y + self.tableView.frame.origin.y
                
                let desiredScrollOffset = headerFrameInTableView.origin.y - self.categoryBarHeight - self.view.safeAreaInsets.top
                
                // Убедитесь, что мы не прокручиваем выше верхней части содержимого табличного представления
                let minScrollOffset = -self.tableView.adjustedContentInset.top
                let finalScrollOffset = max(minScrollOffset, desiredScrollOffset)
                
                self.tableView.setContentOffset(CGPoint(x: 0, y: finalScrollOffset), animated: true)
            }
        }
    }
}
