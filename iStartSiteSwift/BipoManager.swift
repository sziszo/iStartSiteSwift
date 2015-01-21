//
//  BipoManager.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 21..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

protocol BipoManager {
    
    func refresh(complete: () -> ())
}

class BipoManagerFactory {
    
    class func defaultManager() -> BipoManager {
        return PBipoManager()
    }
}

private class PBipoManager: BipoManager {
    
    var updatingClass = 0
    
    
    
    func refresh(complete: () -> ()) {
        
        let completeBlock: () -> () = {
            if --self.updatingClass == 0 {
                complete()
            }
        }
        
        updateCompanies(completeBlock)
        updateEmployees(completeBlock)
        
    }
    
    private func updateCompanies(complete: () -> ()) {
        
        self.updatingClass++
        
        let query = PFQuery(className: PCompany.parseClassName())
        query.findObjectsInBackgroundWithBlock { pCompanies, error in
            
            
            if error != nil {
                
                let errorString = error.userInfo?["error"] as String
                println("[ERROR] - updateCompanies: " + errorString)
                return
            }
            
            //TODO save companies
            
            MagicalRecord.saveWithBlock({ localContext in
                
                for pcompany in pCompanies as [PCompany] {
                    
                    let company = Company.MR_createInContext(localContext) as Company!
                    company.companyId = pcompany.companyId
                    company.shortName = pcompany.shortName
                    company.name1 = pcompany.name1
                    company.name2 = pcompany.name2
                    company.name3 = pcompany.name3
                    company.name4 = pcompany.name4
                    company.created = pcompany.createdAt
                    company.modified = pcompany.updatedAt
                    
                    if let creator = User.MR_findFirstByAttribute("userName", withValue: pcompany.creatorId, inContext: localContext) as? User {
                        company.creator = creator
                    }
                    if let modifier = User.MR_findFirstByAttribute("userName", withValue: pcompany.modifierId, inContext: localContext) as? User {
                        company.modifier = modifier
                    }
                }
                }) {
                    success, error in
                    
                    if error != nil {
                        
                        let errorString = error.userInfo?["error"] as String
                        UIAlertView(title: "Updating companies", message: errorString, delegate: nil, cancelButtonTitle: "Ok").show()
                        
                    }
                    
                    //call completion block
                    complete()
                    
                    println("End updating company")
                    
            }
            
            
        }
    }
    
    private func updateEmployees(complete: () -> ()) {
        
        self.updatingClass++
        
        let query = PFQuery(className: PCompany.parseClassName())
        query.findObjectsInBackgroundWithBlock { pCompanies, error in
            
            //TODO save companies
            
            //call completion block
            complete()
        }
    }
    
}

class BipoTestDataManager {
    
    class func uploadTestData() {
        
        
        let creatorId = "BM900334"
        let modifierId = creatorId
        
        let companyId1 = 1
        createCompany(companyId1) {
            println("insert test company")
            let company = PCompany()
            company.name1 = "CodeProject"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "cp"
            company.companyId = companyId1
            company.creatorId = creatorId
            company.modifierId = modifierId
            
            company.save()
            println("company is saved")
        }
        
        let companyId2 = 2
        createCompany(companyId2) {
            println("insert test company")
            let company = PCompany()
            company.name1 = "Google"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "google"
            company.companyId = companyId2
            company.creatorId = creatorId
            company.modifierId = modifierId
            
            company.save()
            println("company is saved")
        }
        
        let companyId3 = 3
        createCompany(companyId3) {
            println("insert test company")
            let company = PCompany()
            company.name1 = "MyCompany Inc"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "mycomp"
            company.companyId = companyId3
            company.creatorId = creatorId
            company.modifierId = modifierId
            
            company.save()
            println("company is saved")
        }
        
        let companyId4 = 4
        createCompany(companyId4) {
            println("insert test company")
            let company = PCompany()
            company.name1 = "PRex Inc"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "mycomp"
            company.companyId = companyId4
            company.creatorId = creatorId
            company.modifierId = modifierId
            
            company.save()
            println("company is saved")
        }
        
        let companyId5 = 5
        createCompany(companyId5) {
            println("insert test company")
            let company = PCompany()
            company.name1 = "XYZ Group"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "xyz"
            company.companyId = companyId5
            company.creatorId = creatorId
            company.modifierId = modifierId
            
            company.save()
            println("company is saved")
        }
        
    }
    
    private class func createCompany(companyId: Int, companyCreatorMethod: () -> ()) {
        
        let query = PFQuery(className: PCompany.parseClassName())
        query.whereKey("companyId", equalTo: companyId)
        query.getFirstObjectInBackgroundWithBlock { company, error in
            if company == nil {
                companyCreatorMethod()
            }
        }
    }
}