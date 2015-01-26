//
//  Archive.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(Archive)
class Archive: NSManagedObject {

    @NSManaged var archivedAt: NSDate
    @NSManaged var archiveId: NSNumber
    @NSManaged var archiveStatus: NSNumber
    @NSManaged var archiveGroup: ArchiveGroup
    @NSManaged var company: Company?
    @NSManaged var creator: User
    @NSManaged var employee: Employee?
    @NSManaged var message: MailboxMessage
    @NSManaged var project: Project

}
