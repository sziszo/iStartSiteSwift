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

class PBipoManager: BipoManager {
    
    var runningWorkers = [String : AnyObject]()
    
    func refresh(complete: () -> ()) {
        
        
        let completeBlock: (className: String, error: NSError?) -> () = { className, error in
            
            
            if error != nil {
                
                let errorString = error!.userInfo?["error"] as String
                UIAlertView(title: "Refresh error", message: errorString, delegate: nil, cancelButtonTitle: "Ok").show()
                
            }
            
            println("Downloading \(className) is finished")
            
            //call completion block if all worker finished
            
            self.runningWorkers[className] = nil
            
            if self.runningWorkers.isEmpty {
                complete()
            }
            
        }
        
        refreshPersons(completeBlock)
        refreshUsers(completeBlock)
        refreshCompanies(completeBlock)
        refreshEmployees(completeBlock)
    }
    
    private func refreshPersons(completeBlock: (className: String, error: NSError?) -> ()) {
        
        let worker = PObjectWorker<PPerson>()
        runningWorkers[PPerson.parseClassName()] = worker
        
        worker.savePObjectsInBackgroundWithBlock({ (pperson, localContext) -> () in
            
            let id = pperson.personId
            
            func findPerson() -> Person! {
                var person = Person.MR_findFirstByAttribute("personId", withValue: id, inContext: localContext) as? Person
                if person == nil {
                    
                    //create new person
                    println("Create new Person with id \(id)")
                    person  = Person.MR_createInContext(localContext) as Person!
                    
                }
                return person
            }
            
            if let person = findPerson() {
                person.personId = id
                person.name1 = pperson.name1
                person.name2 = pperson.name2
            }
            
        }, complete: completeBlock)
    }
    
    private func refreshUsers(completeBlock: (className: String, error: NSError?) -> ()) {
        
        let worker = PObjectWorker<PUser>()
        runningWorkers[PUser.parseClassName()] = worker
        
        worker.savePObjectsInBackgroundWithBlock({ (puser, localContext) -> () in
            
            let id = puser.userName
            
            func findUser() -> User! {
                var user = User.MR_findFirstByAttribute("userName", withValue: id, inContext: localContext) as? User
                if user == nil {
                    println("Create User with id \(id)")
                    user  = User.MR_createInContext(localContext) as User!
                }
                return user
            }
            
            if let user = findUser() {
                user.userName = id
                
                if let person = Person.MR_findFirstByAttribute("personId", withValue: puser.personId, inContext: localContext) as? Person {
                    user.person = person
                }
            }
            
            }, complete: completeBlock)
    }


    
    private func refreshCompanies(completeBlock: (className: String, error: NSError?) -> ()) {
        
        let worker = PObjectWorker<PCompany>()
        runningWorkers[PCompany.parseClassName()] = worker
        
        worker.savePObjectsInBackgroundWithBlock({ (pcompany, localContext) -> () in
            
            let id = pcompany.companyId
            
            func findCompany() -> Company! {
                var company = Company.MR_findFirstByAttribute("companyId", withValue: id, inContext: localContext) as? Company
                if company == nil {
                    println("Create Company with id \(id) exists")
                    company = Company.MR_createInContext(localContext) as Company!
                }
                return company
            }
            
            if let company = findCompany() {
                company.companyId = id
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
            
            }, complete: completeBlock)
        
    }
    
    private func refreshEmployees(completeBlock: (className: String, error: NSError?) -> ()) {
        
        let worker = PObjectWorker<PEmployee>()
        runningWorkers[PEmployee.parseClassName()] = worker
        
        worker.savePObjectsInBackgroundWithBlock({ (pemployee, localContext) -> () in
            
            
            let id = pemployee.employeeId
            
            func findEmployee() -> Employee! {
                var employee = Employee.MR_findFirstByAttribute("employeeId", withValue: id, inContext: localContext) as? Employee
                if employee == nil {
                    
                    println("Create Employee with id \(id)")
                    employee = Employee.MR_createInContext(localContext) as Employee!
                    
                }
                
                return employee
            }
            
            if let employee = findEmployee() {
                employee.employeeId = id
                
                if let company = Company.MR_findFirstByAttribute("companyId", withValue: pemployee.companyId, inContext: localContext) as? Company {
                    employee.company = company
                }
                
                if let person = Person.MR_findFirstByAttribute("personId", withValue: pemployee.personId, inContext: localContext) as? Person {
                    employee.person = person
                }
                
                //TODO add creatorId and modifierId
            }
            
            }, complete: completeBlock)
    }
}



private class PObjectWorker<T: PObject> {
    
    let className = T.parseClassName()
    
    func savePObjectsInBackgroundWithBlock(savePObject: (pObject: T, context: NSManagedObjectContext) -> (), complete: (String, NSError?) -> ()) {
        
        
        let query = PFQuery(className: self.className)
        query.findObjectsInBackgroundWithBlock { pObjects, error in
            
            if error != nil {
                
                complete(self.className, error)
                
            } else {
                
                MagicalRecord.saveWithBlock({ localContext in
                    
                    for pObject in pObjects as [T] {
                        
                        savePObject(pObject: pObject, context: localContext)
                        
                    }
                    
                    }) { success, error in
                        
                        complete(self.className, error)
                        
                }
                
            }
            
        }
        
    }
}

class BipoTestDataManager {
    
    class func uploadTestData() {
        
        let manager = BipoTestDataManager()
        
        manager.createAdminUser()
        manager.createXYZ()
        manager.createFunny()
        manager.createMyCompanyInc()
        manager.createApple()
        manager.createGoogle()
        manager.createCodeProject()
        
    }
    
    var creatorId = ""
    var modifierId = ""
    
    var personId = 0
    var companyId = 0
    var employeeId = 0
    
    func createAdminUser() {
        let pids = createPersons([(name1: "Admin", name2: "")])
        let adminUser = createUsersFromPersons(pids)[0]
        creatorId = adminUser
        modifierId = adminUser
    }
    
    func createGoogle() {
        
        let cid = incrementCompanyID()
        createCompany(self.companyId) {
            let company = PCompany()
            company.name1 = "Google Inc."
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "google"
            company.companyId = self.companyId
            company.creatorId = self.creatorId
            company.modifierId = self.modifierId
            
            company.save()
            
            return company
        }
        
        let pids = createPersons([(name1: "Larry", name2: "Page"), (name1: "Erik", name2: "Schmidt")])
        createEmployeesFromPersons(pids, forCompany: cid)
        
    }
    
    func createXYZ() {
        
        let cid = incrementCompanyID()
        createCompany(self.companyId) {
            
            let company = PCompany()
            company.name1 = "XYZ Group"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "xyz"
            company.companyId = self.companyId
            company.creatorId = self.creatorId
            company.modifierId = self.modifierId
            
            company.save()
            
            return company
        }
        
        let pids = createPersons([(name1: "Christian", name2: "XYZ"), (name1: "XYZ", name2: "Tobias")])
        
        createEmployeesFromPersons(pids, forCompany: cid)
        
        createUsersFromPersons(pids)
        
    }
    
    
    func createMyCompanyInc() {
        
        
        let cid = incrementCompanyID()
        createCompany(self.companyId) {
            let company = PCompany()
            company.name1 = "MyCompany Inc"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "mycomp"
            company.companyId = self.companyId
            company.creatorId = self.creatorId
            company.modifierId = self.modifierId
            
            company.save()
            
            return company
        }
        
        let pids = createPersons([(name1: "Szilard", name2: "Antal"), (name1: "Ipszilon", name2: "Iksz"), (name1: "Izsak", name2: "Hat")])
        createEmployeesFromPersons(pids, forCompany: cid)
        
        
    }
    
    func createFunny() {
        
        let cid = incrementCompanyID()
        createCompany(self.companyId) {
            let company = PCompany()
            company.name1 = "Funny Inc"
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "funny"
            company.companyId = self.companyId
            company.creatorId = self.creatorId
            company.modifierId = self.modifierId
            
            company.save()
            
            return company
        }
        
        let pids = createPersons([(name1: "James", name2: "Funny"), (name1: "Peter", name2: "Funny")])
        createEmployeesFromPersons(pids, forCompany: cid)
        
    }
    
    func createApple() {
        
        let cid = incrementCompanyID()
        createCompany(self.companyId) {
            let company = PCompany()
            company.name1 = "Apple Inc."
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "apple"
            company.companyId = self.companyId
            company.creatorId = self.creatorId
            company.modifierId = self.modifierId
            
            company.save()
            
            return company
        }
        
        let pids = createPersons([(name1: "Steve", name2: "Jobs")])
        createEmployeesFromPersons(pids, forCompany: cid)
        
    }
    
    func createCodeProject() {
        
        let cid = incrementCompanyID()
        createCompany(self.companyId) {
            let company = PCompany()
            company.name1 = "CodeProject Inc."
            company.name2 = ""
            company.name3 = ""
            company.name4 = ""
            company.shortName = "codeProject"
            company.companyId = self.companyId
            company.creatorId = self.creatorId
            company.modifierId = self.modifierId
            
            company.save()
            
            return company
        }
        
    }
    
    func createPersons(names: [(name1: String, name2:String)]) -> [Int] {
        
        var pids = [Int]()
        
        for name in names {
            
            let pid = incrementPesonID()
            pids += [pid]
            
            createPerson(pid) {
                
                let person = PPerson()
                person.personId = pid
                person.name1 = name.name1
                person.name2 = name.name2
                
                person.save()
                
                return person
            }
            
        }
        
        return pids
    }
    
    func createEmployeesFromPersons(personIds: [Int], forCompany companyId: Int) {
        
        for pid in personIds {
            
            let eid = incrementEmployeeID()
            createEmployee(eid) {
                
                let employee = PEmployee()
                employee.employeeId = eid;
                employee.companyId = companyId
                employee.personId = pid
                
                employee.save()
                
                return employee
            }
        }
        
    }
    
    func createUsersFromPersons(personIds: [Int]) -> [String] {
        
        var uids = [String]()
        
        for pid in personIds {
            
            let userName = "USR\(pid)"
            uids += [userName]
            createUser(userName) {
                
                let user  = PUser()
                user.userName = userName
                user.personId = pid
                
                user.save()
                
                return user
            }
        }
        
        return uids
    }
    
    func incrementPesonID() -> Int {
        return ++personId
    }
    
    func incrementCompanyID() -> Int {
        return ++companyId
    }
    
    func incrementEmployeeID() -> Int {
        return ++employeeId
    }
    
    private func createUser(userName: String, userCreatorMethod: () -> (PUser)) {
        
        let query = PFQuery(className: PUser.parseClassName())
        query.whereKey("userName", equalTo: userName)
        query.getFirstObjectInBackgroundWithBlock { user, error in
            if user == nil {
                let newUser = userCreatorMethod()
                println("\(newUser.userName) is created!")
            }
        }
    }
    
    private func createPerson(personId: Int, personCreatorMethod: () -> (PPerson)) {
        
        let query = PFQuery(className: PPerson.parseClassName())
        query.whereKey("personId", equalTo: personId)
        query.getFirstObjectInBackgroundWithBlock { person, error in
            if person == nil {
                let newPerson = personCreatorMethod()
                println("\(newPerson.name2), \(newPerson.name1) is created!")
            }
        }
    }
    
    private func createCompany(companyId: Int, companyCreatorMethod: () -> (PCompany)) {
        
        let query = PFQuery(className: PCompany.parseClassName())
        query.whereKey("companyId", equalTo: companyId)
        query.getFirstObjectInBackgroundWithBlock { company, error in
            if company == nil {
                let newCompany = companyCreatorMethod()
                println("\(newCompany.name1) is created!")
            }
        }
    }
    
    private func createEmployee(employeeId: Int, employeeCreatorMethod: () -> (PEmployee)) {
        
        let query = PFQuery(className: PEmployee.parseClassName())
        query.whereKey("employeeId", equalTo: employeeId)
        query.getFirstObjectInBackgroundWithBlock { employee, error in
            if employee == nil {
                let newEmployee = employeeCreatorMethod()
                println("\(newEmployee.employeeId) is created!")
            }
        }
    }
}