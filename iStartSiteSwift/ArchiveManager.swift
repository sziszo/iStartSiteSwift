//
//  ArchiveManager.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 02. 07..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

protocol DataManager {
    
    typealias DataType
    var data: OrderedDictionary<String, [DataType]> { get }
    func fetch(let type: OperationType, let completion: () -> ())
}

enum ArchiveStatus: Int  {
    case NotSet = 0
    case Archived = 1
    case Rejected = 2
}


class ArchiveMessageManager: DataManager {
    typealias DataType = Archive
    
    var data = OrderedDictionary<String, [Archive]>()
    
    func fetch(type: OperationType, completion: () -> ()) {
        
        switch type {
        case .ArchiveMessage(let status):
            fetchArchives(status, completion: completion)
        default:
            println("Invalid operation type! type=\(type)")
        }
        
    }
    
    private func fetchArchives(let currentStatus: ArchiveStatus, let completion: () -> ()) {
        let fetchRequest = Archive.MR_createFetchRequest()
        
        switch currentStatus {
        case .NotSet:
            let sortDescriptor = NSSortDescriptor(key: "message.senderDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
        default:
            let sortDescriptor = NSSortDescriptor(key: "archivedAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
        }
        
        let predicate = NSPredicate(format: "archiveStatus == %d", currentStatus.rawValue)
        fetchRequest.predicate = predicate
        
        var archives = Archive.MR_executeFetchRequest(fetchRequest!) as [Archive]
        
        refreshArhives(archives, byCurrentStatus: currentStatus)
        
        println("loaded archives count: \(archives.count)")
        completion()
    }

    private func refreshArhives(archives: [Archive], byCurrentStatus currentStatus: ArchiveStatus ) {
        
        var groupFunction: (Archive) -> String
        
        switch currentStatus {
        case .NotSet:
            groupFunction = { archive in
                return archive.message.senderDate.dateStringWithFormat("MMM d")
            }
        default:
            groupFunction = { archive in
                return archive.archivedAt.dateStringWithFormat("MMM d")
            }
            
            
        }
        
        self.data = groupingArchives(archives, groupFunction: groupFunction)
        
    }
    
    private func groupingArchives(archives: [Archive], groupFunction: (Archive) -> String) -> OrderedDictionary<String, [Archive]> {
        
        
        var temp = [String : [Archive]]()
        
        for archive in  archives {
            
            let key = groupFunction(archive)
            
            var groupedArchives = [Archive]()
            if let alreadyGroupedArchives = temp[key] {
                groupedArchives = alreadyGroupedArchives
            }
            groupedArchives += [archive]
            
            temp[key] = groupedArchives
            
        }
        
        
        var result = OrderedDictionary<String, [Archive]>()
        
        let sortedKeys = sorted(temp.keys, <)
//        let sortedKeys = temp.keys
        for key in sortedKeys {
            result[key] = temp[key]
        }
        
        return result;
    }
    
    
    
    func setArchiveStatus(status: ArchiveStatus, atIndexPath indexPath: NSIndexPath, withDate: Bool = true ) {
        let archive = data[indexPath.section].value[indexPath.row]
        setArchive(archive, status: status, withDate: withDate)
    }
    
    func setArchive(archive: Archive, status: ArchiveStatus, withDate: Bool ) {
        
        archive.archiveStatus = status.rawValue
        if withDate {
            archive.archivedAt = NSDate()
        }
        
    }

    func removeArchiveAtIndexPath(indexPath: NSIndexPath) {
        let archiveEntry = self.data[indexPath.section]
        var items = archiveEntry.value
        if items.count > 0 {
            items.removeAtIndex(indexPath.row)
            data[archiveEntry.key] = items
        }
    }
    
    func removeKeyAtIndexPath(indexPath: NSIndexPath) {
//        let archiveEntry = data[indexPath.section]
//        data[archiveEntry.key] = nil
        data.removeAtIndex(indexPath.section)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}