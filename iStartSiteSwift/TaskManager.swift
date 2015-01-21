//
//  TaskManager.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 21..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation


public class Task: PFObject, PFSubclassing {
    
    var taskType: String {
        get {
            return objectForKey("taskType") as String
        }
        set {
            setObject(newValue, forKey: "taskType")
        }
    }
    
    var taskDescription: String {
        get {
            return objectForKey("description") as String
        }
        set {
            setObject(newValue, forKey: "description")
        }
    }

    var contactCompany: String {
        get {
            return objectForKey("contactCompany") as String
        }
        set {
            setObject(newValue, forKey: "contactCompany")
        }
    }
    
    var contactEmployee: String {
        get {
            return objectForKey("contactEmployee") as String
        }
        set {
            setObject(newValue, forKey: "contactEmployee")
        }
    }
    
    
    override public class func load() {
        registerSubclass()
    }
    
    public class func parseClassName() -> String! {
        return "Task"
    }
}


class TaskManager {
    
}