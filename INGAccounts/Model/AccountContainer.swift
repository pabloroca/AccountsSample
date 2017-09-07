//
//  AccountContainer.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

struct AccountContainer: Loopable {
    var accounts: [Account]
    var failedAccountTypes: String
    var returnCode: String
    
    init(accounts: [Account], failedAccountTypes: String, returnCode: String) {
        self.accounts = accounts
        self.failedAccountTypes = failedAccountTypes
        self.returnCode = returnCode
    }
    
    init(json: [String : Any]) {
        let accounts = json["accounts"] as? [[String:Any]] ?? []
        let accountsArray = accounts.map { Account(json: $0) }
        
        let failedAccountTypes = json["failedAccountTypes"] as? String ?? ""
        let returnCode = json["returnCode"] as? String ?? ""
        
        self.init(accounts: accountsArray, failedAccountTypes: failedAccountTypes, returnCode: returnCode)
    }
}
