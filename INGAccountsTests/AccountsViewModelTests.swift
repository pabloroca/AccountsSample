//
//  AccountsViewModelTests.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 6/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import XCTest

class AccountsViewModelTests: XCTestCase {
    
    var viewModel: AccountsViewModel?

    override func setUp() {
        super.setUp()
        viewModel = AccountsViewModel()
        let jsonData = PR2Common().readJSONFileAsDict(file: "accounts")
        let accountContainer = AccountContainer(json: jsonData)
        viewModel?.rows = accountContainer.accounts
    }
    
    override func tearDown() {
        self.viewModel = nil
        super.tearDown()
    }
    
    func testchangeshowOnlyVisibleAccounts() {
        XCTAssertEqual(viewModel?.showOnlyVisibleAccounts, true)
        viewModel?.changeshowOnlyVisibleAccounts()
        XCTAssertEqual(viewModel?.showOnlyVisibleAccounts, false)
    }
    
    func testNumberOfRowsInSection() {
        XCTAssertEqual(viewModel?.numberOfRowsInSection(section: 0), 3)
    }
    
    func testNumberOfRows() {
        XCTAssertEqual(viewModel?.numberOfRows(), 3)
    }
    
    func testrow() {
        let row = viewModel?.row(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(row?.title, "Hr P L G N StellingTD")
        XCTAssertEqual(row?.subtitle, "NL82 INGB 0074 8757 54")
    }

}
