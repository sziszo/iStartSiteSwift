//
//  AppDelegate.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let settings = Settings()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        println("applicationDirectoryPath: \(applicationDirectoryPath())")
        
        MagicalRecord.setupCoreDataStack()
        
        setupTestData()
         
        setupParse()
        
        BipoTestDataManager.uploadTestData()
        
        //        let containerViewController = ContainerViewController()
        //
        //        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        //        window!.rootViewController = containerViewController
        //        window!.makeKeyAndVisible()
        
                
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        MagicalRecord.cleanUp()
    }
    
    func applicationDirectoryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as String
    }
    
    // MARK: Appdelegate methods
    class func sharedAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as AppDelegate
    }

    
    
    // MARK: Parse methods
    func setupParse() {
        
        Parse.setApplicationId("your_application_id", clientKey:"your_client_key")
        
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { successed, error in
//            println("testObject is saved!")
//        }
    }
    
    // MARK: mailbox methods
    func getTestAccount() -> Mailbox {
        return Mailbox.MR_findFirstByAttribute("accountName", withValue: "your_gmail_account@gmail.com") as Mailbox
    }
    
    func setupTestData() {
        
        var account = Mailbox.MR_findFirstByAttribute("accountName", withValue: "your_gmail_account@gmail.com") as? Mailbox
        
        if account == nil {
            
            account = Mailbox.MR_createEntity() as Mailbox!
            account?.accountName = "your_gmail_account@gmail.com"
            account?.server = "imap.gmail.com"
            account?.port = NSNumber(unsignedInt: 993)
            account?.loginName = "your_gmail_account"
            account?.password = "your_gmail_password"
            
        }
        
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait();
        
        
        
    }

}

