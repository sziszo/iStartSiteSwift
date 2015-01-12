//
//  User.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

    @NSManaged var userName: String
    @NSManaged var createdArchivingMessages: NSSet
    @NSManaged var createdCompanies: NSSet
    @NSManaged var createdProjects: NSSet
    @NSManaged var modifiedCompanies: NSSet
    @NSManaged var modifiedProjects: NSSet
    @NSManaged var person: Person

}
