//
//  ArchiveGroup.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation
import CoreData

@objc(ArchiveGroup)
class ArchiveGroup: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var archive: NSSet
    @NSManaged var company: Company
    @NSManaged var project: Project

}
