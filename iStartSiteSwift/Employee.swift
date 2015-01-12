//
//  Employee.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Employee)
class Employee: NSManagedObject {

    @NSManaged var employeeId: NSNumber
    @NSManaged var archivingMessages: Archive
    @NSManaged var company: Company
    @NSManaged var contacts: NSSet
    @NSManaged var person: Person

}
