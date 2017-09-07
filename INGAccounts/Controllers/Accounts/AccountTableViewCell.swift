//
//  AccountTableViewCell.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 6/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle.font = UIFont.ingFontNormal()
        lblSubtitle.font = UIFont.ingFontSmall()
    }
    
    func configure(viewModel: AccountTableViewCellViewModel) {
        self.lblTitle.text = viewModel.title
        self.lblSubtitle.text = viewModel.subtitle
        self.lblAmount.attributedText = viewModel.amount
    }
    
}
