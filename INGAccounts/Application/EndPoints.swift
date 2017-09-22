//
//  EndPoints.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 21/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

/// End Points
struct EndPoints {
    
    /// http protocol
    static let httprotocol = "https"
    
    /// base url
    static let mainurl = "\(httprotocol)://quarkbackend.com/getfile/pabloroca/"
    
    /// EP for accounts
    static let accounts = "\(mainurl)accounts-json"

    /// EP for dummy (just a second ep to be able to group then)
    static let status = "\(mainurl)status-json"

}
