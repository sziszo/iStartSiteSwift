//
//  HistoryManager.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 27..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class HistoryManager {
    
    var lastSelectedCompany: Company?
    var lastSelectedEmployee: Employee?
    var lastSelectedOrder: Project?
    
    class var defaultManager: HistoryManager {
        struct Static {
            static var instance: HistoryManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = HistoryManager()
        }
        
        return Static.instance!
    }
    
    
}