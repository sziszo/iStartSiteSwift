//
//  PProject.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 23..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class PProject: PObject {
    
    @NSManaged var projectNr: NSDecimalNumber
    @NSManaged var projectType: String
    @NSManaged var projectYear: NSNumber
    
    @NSManaged var name: String
    @NSManaged var designation: String
    
    @NSManaged var customerId: Int
    
    @NSManaged var creatorId: Int
    @NSManaged var modifierId: Int
    
    override class func parseClassName() -> String! {
        return "PProject"
    }
    
    override class func load() {
        super.load()
        self.registerSubclass()
    }

    

}