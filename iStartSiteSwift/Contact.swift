//
//  Contact.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Contact)
class Contact: NSManagedObject {

    @NSManaged var address: String
    @NSManaged var company: Company
    @NSManaged var emails: NSSet
    @NSManaged var employee: Employee
    @NSManaged var mailboxContact: MailboxContact
    @NSManaged var person: Person

}
