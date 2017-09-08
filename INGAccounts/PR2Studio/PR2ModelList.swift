//
//  PR2ModelList.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 8/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import Foundation

public class PR2ModelList<T> {
    
    var rows: [T] = []
    
    init() {}
    
    func numberOfRowsInSection(section: Int) -> Int {
        return rows.count
    }
    
    func numberOfRows() -> Int {
        return rows.count
    }
    
    func readData(completion: @escaping (Bool) -> Void)  {
    }
    
}
