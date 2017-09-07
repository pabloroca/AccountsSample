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

    func readData(completion: @escaping (Bool) -> Void)  {
//        let jsonData = PR2Common().readJSONFileAsDict(file: "accounts")
//        let accountContainer = AccountContainer(json: jsonData)
//        let accounts = accountContainer.accounts.filter { (account) -> Bool in
//            if (showOnlyVisibleAccounts && account.isVisible) || !showOnlyVisibleAccounts {
//                return true
//            } else {
//                return false
//            }
//        }
//        
//        rows = accounts
//        completion(true)
        
        let request = PR2NetworkTask(method: "GET", url: EndPoints.accounts, params: nil, headers: nil, priority: Operation.QueuePriority.normal, pollforUTC: 0) { [unowned self] (success, response) in
            
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
        
        PR2Networking.sharedInstance.addTask(request)
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
