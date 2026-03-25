//
//  Route.swift
//  TeamHub
//
//  Created by Ayush yadav on 25/03/26.
//

import Foundation

enum Route: Hashable {
    case detail(String)
    case add
    case edit(EmployeeDetail)
}
