//
//  PEmployee.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 21..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class PEmployee: PFObject, PFSubclassing {
    @NSManaged var employeeId: Int
    @NSManaged var archivingMessages: Archive
    @NSManaged var companyId: Int
    
    class func parseClassName() -> String! {
        return "PEmployee"
    }
    
    override class func load() {
        super.load()
        self.registerSubclass()
    }
    
}