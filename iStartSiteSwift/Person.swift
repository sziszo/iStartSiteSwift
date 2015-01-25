//
//  Person.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Person)
class Person: NSManagedObject {

    @NSManaged var name1: String
    @NSManaged var name2: String
    @NSManaged var personId: NSNumber
    @NSManaged var contacts: NSSet
    @NSManaged var employes: NSSet
    @NSManaged var user: User?

}
