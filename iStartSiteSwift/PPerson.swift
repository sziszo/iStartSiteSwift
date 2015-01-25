//
//  PPerson.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 23..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation


class PPerson: PObject {
    
    @NSManaged var personId: Int
    @NSManaged var name1: String
    @NSManaged var name2: String
    
    override class func parseClassName() -> String! {
        return "PPerson"
    }
    
    override class func load() {
        super.load()
        self.registerSubclass()
    }

    
}