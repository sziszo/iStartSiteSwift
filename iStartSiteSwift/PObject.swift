//
//  PObject.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 25..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class PObject: PFObject, PFSubclassing {
    class func parseClassName() -> String! {
        println("parseClassName: \(self.description())")
        
        assert(false, "This method must be overriden by the subclass")
    }
    
}