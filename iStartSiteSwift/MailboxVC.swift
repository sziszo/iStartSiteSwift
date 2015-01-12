//
//  TableViewController.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

import UIKit

enum ArchiveStatus: Int  {
    case NotSet = 0
    case Archived = 1
    case Rejected = 2
}

class MailboxVC: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var archives = [Archive]()
    var currentStatus: ArchiveStatus = .NotSet
    
    @IBOutlet weak var sbgTableView: SBGestureTableView!
    
    let checkIcon = FAKIonIcons.iosCheckmarkIconWithSize(30)
    let closeIcon = FAKIonIcons.iosCloseIconWithSize(30)
    let composeIcon = FAKIonIcons.iosComposeIconWithSize(30)
    let clockIcon = FAKIonIcons.iosClockIconWithSize(30)
    let greenColor = UIColor(red: 85.0/255, green: 213.0/255, blue: 80.0/255, alpha: 1)
    let redColor = UIColor(red: 213.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
    let yellowColor = UIColor(red: 236.0/255, green: 223.0/255, blue: 60.0/255, alpha: 1)
    let brownColor = UIColor(red: 182.0/255, green: 127.0/255, blue: 78.0/255, alpha: 1)
    
    var archiveBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    var rejectBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sbgTableView = self.tableView as SBGestureTableView;
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        navigationItem.rightBarButtonItem = addButton
        
        setupIcons()
        
        
        archiveBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Archive item at \(indexPath)")
            
            //update ArchiveStatus
            self.setArchiveStatus(ArchiveStatus.Archived, atIndexPath: indexPath!)
            
            //remove cell
            self.archives.removeAtIndex(indexPath!.row)
            tableView.removeCell(cell, duration: 0.3, completion: nil)

        }

        rejectBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Reject item at \(indexPath)")

            //update ArchiveStatus
            self.setArchiveStatus(ArchiveStatus.Rejected, atIndexPath: indexPath!)
            
            //remove cell
            self.archives.removeAtIndex(indexPath!.row)
            tableView.removeCell(cell, duration: 0.3, completion: nil)

            

        }
        
        fetchArchives()
    }
    
    
    func setArchiveStatus(status: ArchiveStatus, atIndexPath indexPath: NSIndexPath ) {
        
        let archive = archives[indexPath.row]
        archive.archiveStatus = status.rawValue
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait();
        
    }
    
    func setupIcons() {
        checkIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        closeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        composeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        clockIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
    }
    
    func insertNewObject(sender: AnyObject) {
        
        let archive = Archive.MR_createEntity() as Archive;
        archive.archiveStatus = ArchiveStatus.NotSet.rawValue
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        fetchArchives()
        tableView.reloadData()
    }
    
    func fetchArchives() {
        let fetchRequest = Archive.MR_createFetchRequest()
        
        //        let sortDescriptor = NSSortDescriptor(key: "message.uid", ascending: true)
        //        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "archiveStatus == %d", currentStatus.rawValue)
        fetchRequest.predicate = predicate
        
        archives = Archive.MR_executeFetchRequest(fetchRequest!) as [Archive]
        println("loaded archives count: \(archives.count)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        if segue.identifier == "showDetail" {
        //            if let indexPath = tableView.indexPathForSelectedRow() {
        //                let object = objects[indexPath.row] as NSDate
        //                (segue.destinationViewController as DetailViewController).detailItem = object
        //                tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //            }
        //        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archives.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as SBGestureTableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
        
    }
    
    func configureCell(cell: SBGestureTableViewCell, atIndexPath indexPath: NSIndexPath ) {
        
        let size = CGSizeMake(30, 30)
        
        cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkIcon.imageWithSize(size), color: greenColor, fraction: 0.3, didTriggerBlock: archiveBlock)
//        cell.secondLeftAction = SBGestureTableViewCellAction(icon: closeIcon.imageWithSize(size), color: redColor, fraction: 0.6, didTriggerBlock: removeCellBlock)
        cell.firstRightAction = SBGestureTableViewCellAction(icon: composeIcon.imageWithSize(size), color: yellowColor, fraction: 0.3, didTriggerBlock: rejectBlock)
//        cell.secondRightAction = SBGestureTableViewCellAction(icon: clockIcon.imageWithSize(size), color: brownColor, fraction: 0.6, didTriggerBlock: removeCellBlock)
        
        let archive = archives[indexPath.row]
        cell.textLabel?.text = "\(archive.archiveStatus)";
        
    }
    
}
