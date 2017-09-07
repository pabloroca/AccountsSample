//
//  AccountModelTests.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 5/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import XCTest

class AccountModelTests: XCTestCase {
    
    func testInitJSON() {
        let jsonData = PR2Common().readJSONFileAsDict(file: "accounts")
        
        let accountContainer = AccountContainer(json: jsonData)
        XCTAssertEqual(accountContainer.failedAccountTypes , "CREDITCARDS")
        XCTAssertEqual(accountContainer.returnCode , "OK")
        XCTAssertEqual(accountContainer.accounts.count , 3)

        // I test latest account, who is the more complete
        if let accountLast = accountContainer.accounts.last {
            XCTAssertEqual(accountLast.accountBalanceInCents, 15000)
            XCTAssertEqual(accountLast.accountCurrency, "EUR")
            XCTAssertEqual(accountLast.accountId, 700000027559)
            XCTAssertEqual(accountLast.accountName, "third account")
            XCTAssertEqual(accountLast.accountNumber, "H177-27066")
            XCTAssertEqual(accountLast.accountType, .saving)
            XCTAssertEqual(accountLast.alias, "SAVINGS")
            XCTAssertEqual(accountLast.iban, "NL40INGB0074862542")
            XCTAssertEqual(accountLast.isVisible, true)
            XCTAssertEqual(accountLast.linkedAccountId, 748757694)
            XCTAssertEqual(accountLast.productName, "OranjeSpaarrekening")
            XCTAssertEqual(accountLast.productType, 1000)
            XCTAssertEqual(accountLast.savingsTargetReached, true)
            XCTAssertEqual(accountLast.targetAmountInCents, 2000)
        }
    }
    
}
