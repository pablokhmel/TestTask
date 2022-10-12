//
//  HomeTabBarVC.swift
//  TestTask
//
//  Created by MacBook on 10.10.2022.
//

import UIKit

class HomeTabBarVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        tabBar.tintColor = .label
        setupVCs()
    }

    fileprivate func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        return navController
    }

    func setupVCs() {
        viewControllers = [
            createNavController(for: FeedVC(viewModel: FeedVM()), title: "Feed", image: UIImage(systemName: "photo")!),
            createNavController(for: FavoriteVC(viewModel: FavoriteVM()), title: "Favorite", image: UIImage(systemName: "star.fill")!)
        ]
    }
}
