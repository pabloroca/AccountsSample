//
//  AccountsCoordinator.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

final class AccountsCoordinator: Coordinator {
    
    fileprivate let navigationController:UINavigationController
    fileprivate let accountsViewController:AccountsViewController
    
    fileprivate var isaccountsViewController:Bool {
        guard let _ = navigationController.topViewController?.isKind(of: AccountsViewController.self) else { return false }
        return true
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        #if MockEnvironment
            let viewModel = AccountsViewModelMocked()
        #else
            let viewModel = AccountsViewModel()
        #endif
        
        self.accountsViewController = AccountsViewController(viewModel: viewModel)
    }
    
    deinit {
        print("deallocing \(self)")
    }
    
    func start() {
        
        guard let topViewController = navigationController.topViewController else {
            return navigationController.setViewControllers([accountsViewController], animated: false)
        }
        
        //simple animation function
        accountsViewController.view.frame = topViewController.view.frame
        UIView.transition(from:topViewController.view , to: accountsViewController.view, duration: 0.50, options: .transitionCrossDissolve) {[unowned self] (finished) in
            self.navigationController.setViewControllers([self.accountsViewController], animated: false)
        }
        
    }
    
//    fileprivate func showXXXViewController() {
//        let viewModel = XXXViewModel()
//        let viewController = XXXViewController(viewModel: viewModel)
//        navigationController.show(viewController, sender: self)
//    }
    
}
