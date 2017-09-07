//
//  Accounts.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

enum AccountType {
    case payment
    case saving
    case unknown
    
    init(value: String) {
        switch value {
        case "PAYMENT":
            self = .payment
        case "SAVING":
            self = .saving
        default:
            self = .unknown
        }
    }
}

struct Account: Loopable {
    var accountBalanceInCents: Double
    var accountCurrency: String
    var accountId: Double
    var accountName: String
    var accountNumber: String
    var accountType: AccountType
    var alias: String
    var iban: String
    var isVisible: Bool
    
    var linkedAccountId: Double?
    var productName: String?
    var productType: Int?
    var savingsTargetReached: Bool?
    var targetAmountInCents: Double?

    init(accountBalanceInCents: Double, accountCurrency: String, accountId: Double, accountName: String, accountNumber: String, accountType: AccountType, alias: String, iban: String, isVisible: Bool, linkedAccountId: Double?, productName: String?, productType: Int?, savingsTargetReached: Bool?, targetAmountInCents: Double?) {
    
        self.accountBalanceInCents = accountBalanceInCents
        self.accountCurrency = accountCurrency
        self.accountId = accountId
        self.accountName = accountName
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.alias = alias
        self.iban = iban
        self.isVisible = isVisible
        self.linkedAccountId = linkedAccountId
        self.productName = productName
        self.productType = productType
        self.savingsTargetReached = savingsTargetReached
        self.targetAmountInCents = targetAmountInCents
    }

    init(json: [String : Any]) {
        let accountBalanceInCents = json["accountBalanceInCents"] as? Double ?? 0
        let accountCurrency = json["accountCurrency"] as? String ?? ""
        let accountId = json["accountId"] as? Double ?? 0
        let accountName = json["accountName"] as? String ?? ""
        let accountNumber = json["accountNumber"] as? String ?? ""
        let accountType = AccountType(value: json["accountType"] as? String ?? "")
        let alias = json["alias"] as? String ?? ""
        let iban = json["iban"] as? String ?? ""
        let isVisible = json["isVisible"] as? Bool ?? true
        let linkedAccountId = json["linkedAccountId"] as? Double ?? nil
        let productName = json["productName"] as? String ?? nil
        let productType = json["productType"] as? Int ?? nil
        let savingsTargetReached = json["savingsTargetReached"] as? Bool ?? nil
        let targetAmountInCents = json["targetAmountInCents"] as? Double ?? nil
        
        self.init(accountBalanceInCents: accountBalanceInCents, accountCurrency: accountCurrency, accountId: accountId, accountName: accountName, accountNumber: accountNumber, accountType: accountType, alias: alias, iban: iban, isVisible: isVisible, linkedAccountId: linkedAccountId, productName: productName, productType: productType, savingsTargetReached: savingsTargetReached, targetAmountInCents: targetAmountInCents)
    }
}
