//
//  AccountsViewModel.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

public class AccountsViewModel {
    
    var rows: [Account] = []
    var showOnlyVisibleAccounts: Bool = true
    
    static let formatter: NumberFormatter = {
        let _formatter = NumberFormatter()
        _formatter.numberStyle = .decimal
        _formatter.minimumFractionDigits = 2
        _formatter.maximumFractionDigits = 2
        _formatter.generatesDecimalNumbers = true
        return _formatter
    }()
    
    init() {}
    
    func changeshowOnlyVisibleAccounts() {
        showOnlyVisibleAccounts = !showOnlyVisibleAccounts
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return rows.count
    }
    
    func numberOfRows() -> Int {
        return rows.count
    }
    
    // makes two network requests in parallels (concurrently)
    func readData(completion: @escaping (Bool) -> Void)  {
        let groupAccounts = DispatchGroup()
        
        groupAccounts.enter()
        let requestStatus = PR2NetworkTask(method: "GET", url: EndPoints.status, params: nil, headers: nil, priority: Operation.QueuePriority.normal, pollforUTC: 0) { (success, response) in
            // we do nothing here, its just for demo purposes
            groupAccounts.leave()
        }

        groupAccounts.enter()
        let requestAccounts = PR2NetworkTask(method: "GET", url: EndPoints.accounts, params: nil, headers: nil, priority: Operation.QueuePriority.normal, pollforUTC: 0) { [unowned self] (success, response) in
            
            if let result = response.result.value {
                let json = result as! [String: Any]
                let accountContainer = AccountContainer(json: json)
                
                let accounts = accountContainer.accounts.filter { (account) -> Bool in
                    if (self.showOnlyVisibleAccounts && account.isVisible) || !self.showOnlyVisibleAccounts {
                        return true
                    } else {
                        return false
                    }
                }
                
                self.rows = accounts
                groupAccounts.leave()
            }
        }
        
        groupAccounts.notify(queue: .main) {
            completion(true)
        }
        
        PR2Networking.sharedInstance.addTask(requestStatus)
        PR2Networking.sharedInstance.addTask(requestAccounts)
    }
    
    // makes two network requests serial requestAccounts waits to requestStatus finish
    func readDataWithDependency(completion: @escaping (Bool) -> Void)  {
        
        let requestStatus = PR2NetworkTask(method: "GET", url: EndPoints.status, params: nil, headers: nil, priority: Operation.QueuePriority.normal, pollforUTC: 0) { (success, response) in
            // we do nothing here, its just for demo purposes
        }
        
        let requestAccounts = PR2NetworkTask(method: "GET", url: EndPoints.accounts, params: nil, headers: nil, priority: Operation.QueuePriority.normal, pollforUTC: 0) { [unowned self] (success, response) in
            
            if let result = response.result.value {
                let json = result as! [String: Any]
                let accountContainer = AccountContainer(json: json)
                
                let accounts = accountContainer.accounts.filter { (account) -> Bool in
                    if (self.showOnlyVisibleAccounts && account.isVisible) || !self.showOnlyVisibleAccounts {
                        return true
                    } else {
                        return false
                    }
                }
                
                self.rows = accounts
                completion(true)
            }
        }
        
        requestAccounts.addDependency(requestStatus)

        PR2Networking.sharedInstance.addTask(requestStatus)
        PR2Networking.sharedInstance.addTask(requestAccounts)
    }
    
    func row(at indexpath: IndexPath) -> AccountTableViewCellViewModel {
        let row = rows[indexpath.row]
        var rowViewModel: AccountTableViewCellViewModel = AccountTableViewCellViewModel(title: "", subtitle: "", amount: NSAttributedString())
        
        rowViewModel.title = (!row.alias.isEmpty) ? row.alias : row.accountName
        rowViewModel.subtitle = (row.accountType == .payment) ? row.iban.asIban() : row.accountNumber
        
        let balanceString = AccountsViewModel.formatter.string(from: row.accountBalanceInCents/100 as! NSDecimalNumber)!
        rowViewModel.amount = NSAttributedString.balanceText(balanceString: balanceString,
                                                             currency: row.accountCurrency,
                                                             balanceFont: UIFont.ingFontBalance(),
                                                             currencyFont: UIFont.ingFontBalanceCurrency(),
                                                             currencyBaselineOffset: 5)
        
        return rowViewModel
    }
}
