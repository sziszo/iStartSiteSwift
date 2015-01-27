//
//  MailboxMessage.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(MailboxMessage)
class MailboxMessage: NSManagedObject {

    @NSManaged var contentHtml: String?
    @NSManaged var content: String?
    @NSManaged var senderDate: NSDate
    @NSManaged var subject: String
    @NSManaged var uid: NSNumber
    @NSManaged var archiveInfo: Archive
    @NSManaged var folder: MailboxFolder
    @NSManaged var receivers: NSSet
    @NSManaged var senders: NSSet

}
