//
//  ContactEmail.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(ContactEmail)
class ContactEmail: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var contact: Contact

}
