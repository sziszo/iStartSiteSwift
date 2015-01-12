//
//  Project.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Project)
class Project: NSManagedObject {

    @NSManaged var created: NSDate
    @NSManaged var designation: String
    @NSManaged var history: NSDate
    @NSManaged var modified: NSDate
    @NSManaged var name: String
    @NSManaged var projectNr: NSDecimalNumber
    @NSManaged var projectType: String
    @NSManaged var projectYear: NSNumber
    @NSManaged var archiveGroups: NSSet
    @NSManaged var archivingMessages: NSSet
    @NSManaged var creator: User
    @NSManaged var customer: Company
    @NSManaged var modifier: User

}
