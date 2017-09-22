//
//  AccountsInterfaceController.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 22/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import WatchKit
import Foundation

class AccountsInterfaceController: WKInterfaceController {
    
    @IBOutlet var accountTable: WKInterfaceTable!

    var viewModel: AccountsViewModel = AccountsViewModel()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        loadTableData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    fileprivate func loadTableData() {
        
        viewModel.readData {[unowned self] (success) in
            self.accountTable.setNumberOfRows(self.viewModel.numberOfRows(), withRowType: "AccountsTableRowController")
            
            for index in 0..<self.viewModel.numberOfRows() {
                let rowViewModel = self.viewModel.row(at: IndexPath(row: index, section: 0))
                let row = self.accountTable.rowController(at: index) as! AccountsTableRowController
                row.lblTitle.setText(rowViewModel.title)
                row.lblAmount.setAttributedText(rowViewModel.amount)
            }
        }
        
    }
}
