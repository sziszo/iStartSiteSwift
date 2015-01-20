//
//  MailboxContact.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(MailboxContact)
class MailboxContact: NSManagedObject {

    @NSManaged var displayName: String?
    @NSManaged var emailAddress: String
    @NSManaged var contact: Contact
    @NSManaged var receivedMessages: NSSet
    @NSManaged var sentMessages: NSSet

}

extension MailboxContact {
    
    func addSentMessage(message: MailboxMessage) {
        self.mutableSetValueForKey("sentMessages").addObject(message)
    }
    
    func addReceivedMessage(message: MailboxMessage) {
        self.mutableSetValueForKey("receivedMessages").addObject(message)
    }
}
