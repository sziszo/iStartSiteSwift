//
//  Categories.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 13..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

extension NSDate {
    
    func dateStringWithFormat(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}

extension NSSet {
    
    func toString() -> String {
        var toString = ""
        for element in self {
            toString += "\(element)"
        }
        return toString
    }
}

extension MailboxMessage {
    
    func toStringSenders() -> String {
        var toString = "";
        for contact in self.senders {
            toString += contact.toString()
        }
        return toString
    }
    
    func toStringReceivers() -> String {
        var toString = "";
        for contact in self.receivers {
            toString += contact.toString()
        }
        return toString
    }
}

extension MailboxContact {
    
    func toString() -> String {
        var name = self.displayName
        if name == nil || name!.isEmpty {
            name = self.emailAddress
        }
        return name!
    }
    
    var monogram: String {
        var monogram = self.toString()
        return monogram.substringToIndex(monogram.startIndex.successor()).capitalizedString
    }
}

extension Company {
    
    func formattedCompanyName() -> String {
        var toString = ""
        
        if (!self.name1.isEmpty) {
            toString += "\(self.name1) "
        }
        
        if (!self.name2.isEmpty) {
            toString += "\(self.name2) "
        }
        
        if (!self.name3.isEmpty) {
            toString += "\(self.name3) "
        }
        
        if (!self.name4.isEmpty) {
            toString += "\(self.name4)"
        }
        
        if (toString.isEmpty) {
            toString = "Unknown company name"
        }
        
        return toString
    }
}

extension Person {
    
    func formattedPersonName() -> String {
        return "\(self.name1) , \(self.name2)"
    }
}