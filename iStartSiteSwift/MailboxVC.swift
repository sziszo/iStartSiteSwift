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

class MessageCell: SBGestureTableViewCell {
    @IBOutlet weak var senderLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    @IBOutlet weak var contentLabel: UILabel?
    @IBOutlet weak var senderDateLabel: UILabel?
}

class ArchivedCell: SBGestureTableViewCell {
    @IBOutlet weak var companyLabel: UILabel?
    @IBOutlet weak var subjectLabel: UILabel?
    @IBOutlet weak var personLabel: UILabel?
    @IBOutlet weak var orderNrLabel: UILabel?
    @IBOutlet weak var archivedAtLabel: UILabel?
}


class MailboxVC: UITableViewController, UITableViewDataSource, UITableViewDelegate, MenuViewControllerDelegate, CenterViewController {
    
    var archives = [Archive]()
    var currentStatus: ArchiveStatus = .NotSet
    
    @IBOutlet weak var sbgTableView: SBGestureTableView!
    
    let menuIcon = FAKIonIcons.androidMenuIconWithSize(30)
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
    
    var delegate: CenterViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sbgTableView = self.tableView as SBGestureTableView;
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        navigationItem.rightBarButtonItem = addButton
        
        let size = CGSizeMake(30, 30)
        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem?.image = menuIcon.imageWithSize(size)
        
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
        
        
        //setup refreshcontrol
        initRefreshControl()
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
    
    // MARK: refreshControl 
    
    func initRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh!")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = refreshControl

    }
    
    func refresh(sender:AnyObject) {
        
        let mailboxManager = MailboxManager(account: AppDelegate.sharedAppDelegate().getTestAccount())
        
        mailboxManager.fetchMessages() {
            println("fetching  is finished")
        }

        Timer.start(3, repeats: false) {
            self.tableView.reloadData()
            
            self.refreshControl?.endRefreshing()
            
            let lastUpdated = NSDate().dateStringWithFormat("MMM d, h:mm:ss")
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refersh! Last updated on \(lastUpdated)")
            println("end refreshing")
        }
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
        
        var cellIdentifier: String
        switch (currentStatus) {
        case .Archived:
            cellIdentifier = "ArchiveCell"
        default:
            cellIdentifier = "MessageCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as SBGestureTableViewCell
        
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
        
        var cellIdentifier: String
        switch (currentStatus) {
        case .Archived:
            configureArchivedCell(cell, withArchiveItem: archive)
        default:
            let message = archive.message
            configureMessageCell(cell, withMessage: message)
            
        }
        
    }
    
    func configureMessageCell(cell: SBGestureTableViewCell, withMessage message: MailboxMessage?) {
        
        let messageCell = cell as MessageCell
        
//        messageCell.contentLabel?.text = message?.content
        messageCell.subjectLabel?.text = message?.subject
        messageCell.senderDateLabel?.text = message?.senderDate.dateStringWithFormat("MMM d")
        messageCell.senderLabel?.text = "Test@gmail.com"
    }
    
    func configureArchivedCell(cell: SBGestureTableViewCell, withArchiveItem archived: Archive) {
        
        func getFormattedCompany() -> String {
            let company: Company? = archived.company
            return company != nil ? company!.formattedCompanyName() : "Unknown company"
        }
        
        func getFormattedPerson() -> String {
            let person: Person? = archived.employee.person
            return person != nil ? person!.formattedPersonName() : "Unknown person"
        }
        
        func getFormattedOrder() -> String {
            return "Unknown order"
        }
        
        let archivedCell = cell as ArchivedCell
        archivedCell.companyLabel?.text = getFormattedCompany()
        archivedCell.personLabel?.text = getFormattedPerson()
        archivedCell.orderNrLabel?.text = getFormattedOrder()
        archivedCell.archivedAtLabel?.text = archived.archivedAt.dateStringWithFormat("MMM d")
        
        let message = archived.message;
        archivedCell.subjectLabel?.text = message.subject;
    }
    
    // MARK: MenuVIewController
    
    func menuSelected(archiveStatus: ArchiveStatus) {
        self.currentStatus = archiveStatus
        
        fetchArchives()
        self.tableView.reloadData()
        
        delegate?.collapseSidePanels?()
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
}
