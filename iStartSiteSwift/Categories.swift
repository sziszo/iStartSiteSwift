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

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
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
    
    func shortContent(size: Int = 80) -> String {
        if let content = self.content {
            var length = countElements(content)
            if length > size {
                length = size
            }
            return content[0..<length]
        } else {
            return "Content"
        }
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
            toString += self.name1
        }
        
        if let name2 = self.name2 {
            if !name2.isEmpty {
                toString += name2
            }
        }
        
        if let name3 = self.name3 {
            if !name3.isEmpty {
                toString += name3
            }
        }
        
        if let name4 = self.name4 {
            if !name4.isEmpty {
                toString += name4
            }
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