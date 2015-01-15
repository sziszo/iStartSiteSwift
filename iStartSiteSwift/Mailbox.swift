//
//  Mailbox.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Mailbox)
class Mailbox: NSManagedObject {

    @NSManaged var accountName: String
    @NSManaged var lastSyncDate: NSDate
    @NSManaged var loginName: String
    @NSManaged var password: String
    @NSManaged var port: NSNumber
    @NSManaged var server: String
    @NSManaged var sslAuth: NSNumber
    @NSManaged var folders: NSSet

}

extension Mailbox {
    
    func addFolder(folder: MailboxFolder) {
        self.mutableSetValueForKey("folders").addObject(folder)
    }
    
}
