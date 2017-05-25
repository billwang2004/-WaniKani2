//✅
//  DashboardCoordinator.swift
//  WaniKani
//
//  Created by Andriy K. on 3/14/16.
//  Copyright © 2016 Andriy K. All rights reserved.
//

import UIKit

class DashboardCoordinator: Coordinator, DashboardViewControllerDelegate/*, ReviewCoordinatorDelegate*/ {

  struct Constants {
    static let dashboardTitle = "Dashboard"
    static let dashboardTabIconName = "dashboard"

    struct Path {
      static let lesson = IndexPath(item: 0, section: 1)
      static let review = IndexPath(item: 1, section: 1)
    }
  }

  let presenter: UINavigationController
  let dashboardViewController: DashboardViewController
  let dataProvider: DataProvider
  let settingsSuit: SettingsSuit

  fileprivate var reviewCoordinator: ReviewCoordinator?

  init(dataProvider: DataProvider, presenter: UINavigationController, settingsSuit: SettingsSuit) {
    self.dataProvider = dataProvider
    self.presenter = presenter
    self.settingsSuit = settingsSuit
    dashboardViewController = DashboardViewController.instantiateViewController()
    let tabItem: UITabBarItem = UITabBarItem(title: Constants.dashboardTitle, image: UIImage(named: Constants.dashboardTabIconName), selectedImage: nil)
    presenter.tabBarItem = tabItem
  }

  func start() {
    dashboardViewController.delegate = self
    presenter.pushViewController(dashboardViewController, animated: false)
    _ = dashboardViewController.view
    dataProvider.fetchKanji()
    dataProvider.fetchRadicals()
    dataProvider.fetchWords()
    fetchAllDashboardData()
  }

}

// MARK: - DashboardViewControllerDelegate
extension DashboardCoordinator {

  func dashboardPullToRefreshAction() {
    fetchAllDashboardData()
  }

  func didSelectCell(_ indexPath: IndexPath) {
    switch indexPath {
    case Constants.Path.lesson: showLessons()
    case Constants.Path.review: showReviews()
    default:
      break
    }
  }

  func showReviews() {
    reviewCoordinator = ReviewCoordinator(presenter: presenter, type: .review, settingsSuit: settingsSuit)
    reviewCoordinator?.start()
  }

  func showLessons() {
    reviewCoordinator = ReviewCoordinator(presenter: presenter, type: .lesson, settingsSuit: settingsSuit)
    reviewCoordinator?.start()
  }

}
