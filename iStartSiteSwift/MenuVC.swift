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
    
    var delegate: MenuViewControllerDelegate?
    
    let menus = ["Mailbox", "Archived", "Rejected"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("menues: \(menus)")
        
        tableView.reloadData()
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
        
        cell.textLabel?.text = menus[indexPath.row]
        
        return cell
    }
    
    // Mark: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMenu = menus[indexPath.row]
        println("selected menu is \(selectedMenu)")
        delegate?.menuSelected(ArchiveStatus(rawValue: indexPath.row)!)
    }

}