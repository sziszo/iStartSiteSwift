//
//  MenuVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 16..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

protocol MenuViewControllerDelegate {
    func menuSelected(archiveStatus: ArchiveStatus)
}

class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var delegate: MenuViewControllerDelegate!
    
    let menus = ["Mailbox", "Archived", "Rejected"]
    
    let checkIcon = FAKIonIcons.iosCheckmarkOutlineIconWithSize(30)
    let closeIcon = FAKIonIcons.iosCloseOutlineIconWithSize(30)
    let emailIcon = FAKIonIcons.iosEmailOutlineIconWithSize(30)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtLoggedInUser: UILabel!
    @IBOutlet weak var loginView: UIView!
    
//    let defaultBackgroundColor = MP_HEX_RGB("D1EEFC")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Appearance.Menu.tableViewBackground
        self.tableView.backgroundColor = Appearance.Menu.tableViewBackground
        
        println("menues: \(menus)")
        
//        let navColor = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1.0)
        loginView.backgroundColor = Appearance.Menu.loginViewBackground
        
        tableView.reloadData()
        
        if let currentUser = AppDelegate.sharedAppDelegate().settings.currentUser {
            txtLoggedInUser.text = currentUser.userName
        }
        
        setupIcons()
    }
    
    func setupIcons() {
        checkIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.greenColor())
        closeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor())
        emailIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor())
    }
    
    // MARK: Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as UITableViewCell
        
        let size = CGSizeMake(30, 30)
        
        cell.textLabel?.text = menus[indexPath.row]
        
        let archiveStatus: ArchiveStatus = ArchiveStatus(rawValue: indexPath.row)!
        switch (archiveStatus) {
        case .NotSet:
            cell.imageView?.image = emailIcon.imageWithSize(size)
        case .Archived:
            cell.imageView?.image = checkIcon.imageWithSize(size)
        case .Rejected:
            cell.imageView?.image = closeIcon.imageWithSize(size)
        }
        
        cell.backgroundColor = Appearance.Menu.backgroundColor
        return cell
    }
    
    // Mark: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMenu = menus[indexPath.row]
        println("selected menu is \(selectedMenu)")
        delegate.menuSelected(ArchiveStatus(rawValue: indexPath.row)!)
    }

}