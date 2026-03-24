//
//  EmployeePage.swift
//  TeamHub
//
//  Created by Ayush yadav on 24/03/26.
//

import Foundation

struct EmployeePage {
    
    let page: Int
    let pageSize: Int
    
    var offset: Int {
        (page - 1) * pageSize
    }
}
