//
//  PUser.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 23..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class PUser: PObject {
    
    @NSManaged var userName: String
    @NSManaged var personId: Int
    
    override class func parseClassName() -> String! {
        return "PUser"
    }
    
    override class func load() {
        super.load()
        self.registerSubclass()
    }
    
}