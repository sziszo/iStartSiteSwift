//
//  LoginService.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 17..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//


protocol LoginService {
    
    func loginUser(username: String, withPassword password: String, completion: (User?, NSError!) -> ())
    func registerUser(username: String, withPassword passsword: String, completion: (User?, NSError!) -> ())
}

class LoginServiceFactory {
    class func defaultLoginService() -> LoginService {
        return PLoginService()
    }
}

private class PLoginService: LoginService {
    
    init() {
    }
    
    func loginUser(username: String, withPassword password: String, completion: (User?, NSError!) -> ())  {
        
        PFUser.logInWithUsernameInBackground(username, password: password) { pfUser, error in
            
            var loggedInUser: User?
            if pfUser != nil {
                
                //find user
                loggedInUser = User.MR_findFirstByAttribute("userName", withValue: pfUser.username) as? User
                if(loggedInUser == nil) {
                    
                    UIAlertView(title: "Login failed", message: "\(pfUser.username) does not exist in the local database!", delegate: nil, cancelButtonTitle: "Ok").show()
                    return
                }
            }
            
            completion(loggedInUser, error)
        }
        
    }
    
    
    func registerUser(username: String, withPassword passsword: String, completion: (User?, NSError!) -> ()) {
        
        var signedUp = true
        let pfUser = PFUser()
        pfUser.username = username
        pfUser.password = passsword
        
        
        pfUser.signUpInBackgroundWithBlock() { succeeded, error in
            
            var user: User?
            
            if succeeded {
                
                user = User.MR_findFirstByAttribute("userName", withValue: pfUser.username) as? User
                if user == nil {
                    user = User.MR_createEntity() as User!
                    user?.userName = pfUser.username
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                }
                
            }
            
            completion(user, error)
            
        }
        
    }
    
    
}
