//
//  MailboxFolder.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(MailboxFolder)
class MailboxFolder: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var mailbox: Mailbox
    @NSManaged var messages: NSSet

}
