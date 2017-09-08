//
//  AccountsViewModelMocked.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 8/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

public class AccountsViewModelMocked: AccountsViewModel {
    override func readData(completion: @escaping (Bool) -> Void)  {
        let jsonData = PR2Common().readJSONFileAsDict(file: "accounts")
        let accountContainer = AccountContainer(json: jsonData)
        let accounts = accountContainer.accounts.filter { (account) -> Bool in
            if (showOnlyVisibleAccounts && account.isVisible) || !showOnlyVisibleAccounts {
                return true
            } else {
                return false
            }
        }
        
        rows = accounts
        completion(true)
    }
}
