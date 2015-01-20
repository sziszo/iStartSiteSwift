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


class MailboxVC: UITableViewController, UITableViewDataSource, UITableViewDelegate, MenuViewControllerDelegate, CenterViewController {
    
    var archives = [[Archive]]()
    var sections = [String]()
    
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
        
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        
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
            self.removeItemAtIndexPath(indexPath!)
            tableView.removeCell(cell, duration: 0.3, completion: nil)
            
//            if self.archives[indexPath!.section].isEmpty {
//                //remove section
//                self.archives.removeAtIndex(indexPath!.section)
//                tableView.deleteSections(NSIndexSet(index: indexPath!.section), withRowAnimation: .Fade)
//                
//            }
        }

        rejectBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Reject item at \(indexPath)")

            //update ArchiveStatus
            self.setArchiveStatus(ArchiveStatus.Rejected, atIndexPath: indexPath!)
            
            //remove cell
            self.removeItemAtIndexPath(indexPath!)
            tableView.removeCell(cell, duration: 0.3, completion: nil)

//            if self.archives[indexPath!.section].isEmpty {
//                //remove section
//                self.archives.removeAtIndex(indexPath!.section)
//                tableView.deleteSections(NSIndexSet(index: indexPath!.section), withRowAnimation: .Fade)
//                
//            }
            
        }
        
        fetchArchives()
        
        
        //setup refreshcontrol
        initRefreshControl()
    }
    
    func removeItemAtIndexPath(indexPath: NSIndexPath) {
        var items = self.archives[indexPath.section]
        if items.count > 0 {
            items.removeAtIndex(indexPath.row)
            self.archives[indexPath.section] = items
        }
    }
    
    
    func setArchiveStatus(status: ArchiveStatus, atIndexPath indexPath: NSIndexPath ) {
        
        let archive = archives[indexPath.section][indexPath.row]
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
        
        var archives = Archive.MR_executeFetchRequest(fetchRequest!) as [Archive]
        
        let groupedArchives = grouppingArchives(archives)
        
        self.sections = groupedArchives.sections
        self.archives = groupedArchives.grouped
        
        println("loaded archives count: \(archives.count)")
        
    }
    
    func grouppingArchives(archives: [Archive]) -> (sections: [String], grouped: [[Archive]]) {
        var grouped = [[Archive]]()
        var sections = [String]()
        
        for archive in archives {
            let sent = archive.message.senderDate.dateStringWithFormat("MMM d")
            
            
            if( !contains(sections, sent) ) {
                sections.append(sent)
            }
            
            if let index = find(sections, sent) {
                
                var items = [Archive]()
                if index < grouped.count {
                    items = grouped[index]
                } else {
                    grouped.insert([Archive](), atIndex: index)
                }
                items.append(archive)
                grouped[index] = items
                
            }
        }

        return (sections, grouped)
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
        return archives.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRowsInSection: \(section)" )
        return archives[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier: String
        switch (currentStatus) {
        case .Archived:
            cellIdentifier = "ArchiveCell"
        case .NotSet:
            cellIdentifier = "TimelineCell"
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
        
        let archive = archives[indexPath.section][indexPath.row]
        
        switch (currentStatus) {
        case .Archived:
            println("configure archive cell")
            configureArchivedCell(cell, withArchiveItem: archive)
        case .Rejected:
            let message = archive.message
            configureMessageCell(cell, withMessage: message)
        case .NotSet:
            let message = archive.message
            configureTimelineCell(cell, withMessage: message)
        }
        
    }
    
    func configureMessageCell(cell: SBGestureTableViewCell, withMessage message: MailboxMessage?) {
        
        let messageCell = cell as MessageCell
        
//        messageCell.contentLabel?.text = message?.content
        messageCell.subjectLabel?.text = message?.subject
        messageCell.senderDateLabel?.text = message?.senderDate.dateStringWithFormat("MMM d")
        messageCell.senderLabel?.text = "Test@gmail.com"
    }
    
    func configureTimelineCell(cell: SBGestureTableViewCell, withMessage message: MailboxMessage?) {
        
        let timelineCell = cell as TimelineCell2
        
        timelineCell.profileImageView.image = UIImage(named: "person")
        timelineCell.subjectLabel.text = message?.subject
        timelineCell.dateLabel.text = message?.senderDate.dateStringWithFormat("MMM d")
        timelineCell.nameLabel?.text = "Test@gmail.com"
        timelineCell.contentLabel?.text = "Checking out of the hotel today. It was really fun to see everyone and catch up. We should have more conferences like this so we can share ideas."
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//    }
    
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

class TimelineCell2 : SBGestureTableViewCell {
    
    @IBOutlet var typeImageView : UIImageView!
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var dateImageView : UIImageView!
    @IBOutlet var photoImageView : UIImageView?
    
    @IBOutlet var nameLabel : UILabel?
    @IBOutlet var subjectLabel : UILabel!
    @IBOutlet var contentLabel : UILabel?
    @IBOutlet var dateLabel : UILabel!
    
    override func awakeFromNib() {
        
        let size = CGSizeMake(30, 30)
        let menuIcon = FAKIonIcons.iosEmailOutlineIconWithSize(30)
        typeImageView.image = menuIcon.imageWithSize(size)
        typeImageView.layer.cornerRadius = 20
        
//        dateImageView.image = UIImage(named: "clock")
        let size2 = CGSizeMake(15, 15)
        let clockIcon = FAKIonIcons.iosClockOutlineIconWithSize(15);
        dateImageView.image = clockIcon.imageWithSize(size2)
        
        profileImageView.layer.cornerRadius = 30
        
        nameLabel?.font = UIFont(name: "Avenir-Book", size: 16)
        nameLabel?.textColor = UIColor.blackColor()
        
        contentLabel?.font = UIFont(name: "Avenir-Book", size: 14)
        contentLabel?.textColor = UIColor(white: 0.6, alpha: 1.0)
        
        dateLabel.font = UIFont(name: "Avenir-Book", size: 14)
        dateLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        
        photoImageView?.layer.borderWidth = 0.4
        photoImageView?.layer.borderColor = UIColor(white: 0.92, alpha: 1.0).CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if contentLabel != nil {
            let label = contentLabel!
            label.preferredMaxLayoutWidth = CGRectGetWidth(label.frame)
        }
    }
}
