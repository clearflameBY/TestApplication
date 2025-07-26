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
        let router = MainRouter() // ИСПРАВЛЕНО: Теперь инициализируется MainRouter
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController // Теперь router.viewController ожидает MainViewController
        router.dataStore = interactor
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
        let logoImage = UIImage(systemName: "fork.knife.circle.fill") // Example SF Symbol
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.tintColor = .primaryRed
        logoImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "Доставка еды"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .darkGrayText
        
        let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        let customTitleView = UIView()
        customTitleView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: customTitleView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: customTitleView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 30),
            logoImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        self.navigationItem.titleView = customTitleView
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage() // Remove shadow line
        navigationController?.navigationBar.isTranslucent = false
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
        // 1 for banners, 1 for sticky category bar (though it's a separate view), then one for each menu category
        return 1 + menuSections.count // Banners + Menu Sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Banner cell
        } else {
            // Each menu section will display its meals
            let menuSectionIndex = section - 1
            return menuSections[menuSectionIndex].meals.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Banner Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: BannerCell.reuseIdentifier, for: indexPath) as! BannerCell
            // Hardcode banner images
            cell.configure(with: [
                    "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg", // Пример: Chicken Handi
                    "https://s7d1.scene7.com/is/image/mcdonalds/DC_202302_0005-999_BigMac_1564x1564-1:product-header-mobile?wid=1313&hei=1313&dpr=off", // Пример: Big Mac
                    "https://www.themealdb.com/images/media/meals/rvypwy1503069308.jpg"  // Пример: Beef Wellington
                        ])
            return cell
        } else {
            // Meal Cell
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
            return 200 // Height for banner cell
        } else {
            return 120 // Height for meal cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil // No header for banner section
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MenuSectionHeader.reuseIdentifier) as! MenuSectionHeader
            let menuSectionIndex = section - 1
            header.titleLabel.text = menuSections[menuSectionIndex].category.name
            return header
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1 // Smallest possible height to avoid empty space
        } else {
            return 50 // Height for category section header
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let safeAreaTop = view.safeAreaInsets.top
        let scrollOffset = scrollView.contentOffset.y
        
        // Calculate the target Y for the category bar
        // It should stick to the top safe area when scrolled past its initial position
        // The initialCategoryBarY is the bottom of the banner cell
        let stickyY = safeAreaTop
        let currentCategoryBarY = initialCategoryBarY - scrollOffset + safeAreaTop // Adjusted for safe area

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
        // Scroll to the corresponding section in the table view
        guard index < menuSections.count else { return }
        
        // The menu sections start from section 1 in the table view
        let targetSection = index + 1
        
        // Scroll to the header of the target section
        let indexPath = IndexPath(row: 0, section: targetSection)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        // Manually adjust scroll position to ensure the category bar is visible and sticky
        // This is a bit tricky because `scrollToRow` might not perfectly align
        // We want the top of the section to be just below the sticky category bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Small delay to allow scroll to complete
            if self.tableView.headerView(forSection: targetSection) != nil {
                let headerFrameInTableView = self.tableView.rectForHeader(inSection: targetSection)
                _ = headerFrameInTableView.origin.y - self.tableView.contentOffset.y + self.tableView.frame.origin.y
                
                let desiredScrollOffset = headerFrameInTableView.origin.y - self.categoryBarHeight - self.view.safeAreaInsets.top
                
                // Ensure we don't scroll above the top of the table view content
                let minScrollOffset = -self.tableView.adjustedContentInset.top
                let finalScrollOffset = max(minScrollOffset, desiredScrollOffset)
                
                self.tableView.setContentOffset(CGPoint(x: 0, y: finalScrollOffset), animated: true)
            }
        }
    }
}
