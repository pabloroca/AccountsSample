//
//  AppCoordinator.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

class Coordinator {
    var viewController: UIViewController? { return nil }
}

final class AppCoordinator: Coordinator {
    
    fileprivate let navigationController: UINavigationController
    override var viewController: UIViewController? {
        get { return navigationController }
    }
    
    fileprivate var childCoordinators = [Coordinator]()
    
    init(with navigationController:UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {
        print("deallocing \(self)")
    }
    
    func start() {
        showAccounts()
    }
    
    fileprivate func showAccounts() {
        let accountsCoordinator = AccountsCoordinator(navigationController: navigationController)
        accountsCoordinator.start()
        childCoordinators.append(accountsCoordinator)
    }
    
}
