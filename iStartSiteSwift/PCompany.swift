//
//  PCompany.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 21..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class PCompany: PFObject, PFSubclassing {
    
    @NSManaged var companyId: Int
    @NSManaged var history: NSDate
    @NSManaged var name1: String
    @NSManaged var name2: String
    @NSManaged var name3: String
    @NSManaged var name4: String
    @NSManaged var shortName: String
    @NSManaged var creatorId: String
    @NSManaged var modifierId: String
    
    
    
    class func parseClassName() -> String! {
        return "PCompany"
    }
    
    override class func load() {
        super.load()
        self.registerSubclass()
    }
}