//
//  Company.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Company)
class Company: NSManagedObject {

    @NSManaged var companyId: NSNumber
    @NSManaged var created: NSDate
    @NSManaged var history: NSDate
    @NSManaged var modified: NSDate
    @NSManaged var name1: String
    @NSManaged var name2: String?
    @NSManaged var name3: String?
    @NSManaged var name4: String?
    @NSManaged var shortName: String
    @NSManaged var archiveGroups: NSSet
    @NSManaged var archivingMessages: NSSet
    @NSManaged var contacts: NSSet
    @NSManaged var creator: User
    @NSManaged var employes: NSSet
    @NSManaged var modifier: User
    @NSManaged var projects: NSSet

}
