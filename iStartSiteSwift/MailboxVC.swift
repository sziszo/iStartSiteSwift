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

enum TableStyle {
    case Simple
    case Grouped
}


class MailboxVC: UITableViewController, UITableViewDataSource, UITableViewDelegate, MenuViewControllerDelegate, CenterViewController, ArchiveVCDelegate {
    
    private var archives = [[Archive]]()
    private var sections = [String]()
    
    private var currentStatus: ArchiveStatus = .NotSet
    private var tableStyle: TableStyle = .Simple
    
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
    
    private var archiveBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    private var rejectBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    private var notSetBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    
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
            
            
            let archiveItem = self.archives[indexPath!.section][indexPath!.row]
            
            //remove cell
            self.removeTableView(tableView, cell: cell, atIndexPath: indexPath!)
            
            self.showArchiveVC(archiveItem)
            
        }

        rejectBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Reject item at \(indexPath)")

            //update ArchiveStatus
            self.setArchiveStatus(ArchiveStatus.Rejected, atIndexPath: indexPath!)
            
            //remove cell
            self.removeTableView(tableView, cell: cell, atIndexPath: indexPath!)
            
        }
        
        notSetBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Set item's status at \(indexPath) to NotSet")
            
            //update ArchiveStatus
            self.setArchiveStatus(ArchiveStatus.NotSet, atIndexPath: indexPath!)
            
            //remove cell
            self.removeTableView(tableView, cell: cell, atIndexPath: indexPath!)

        }

        
        fetchArchives()
        
        
        //setup refreshcontrol
        initRefreshControl()
    }
    
    private func removeTableView(tableView: SBGestureTableView, cell: SBGestureTableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        self.removeItemAtIndexPath(indexPath)
        tableView.removeCell(cell, duration: 0.3) {
            var items = self.archives[indexPath.section]
            if items.count == 0 {
                self.archives.removeAtIndex(indexPath.section)
                self.sections.removeAtIndex(indexPath.section)
            }
            
            tableView.reloadData()
            
        }
    }
    
    private func removeItemAtIndexPath(indexPath: NSIndexPath) {
        var items = self.archives[indexPath.section]
        if items.count > 0 {
            items.removeAtIndex(indexPath.row)
            self.archives[indexPath.section] = items
        }
    }
    
    private func showArchiveVC(archiveItem: Archive) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("archiveNavVC") as UINavigationController;
        let archiveVC = vc.topViewController as ArchiveVC
        
        
        
        let formSheetController = MZFormSheetController(viewController: vc)
        formSheetController.shouldDismissOnBackgroundViewTap = true
        self.mz_presentFormSheetController(formSheetController, animated: true) { formSheetController in
            println("form sheet is displayed!")
            if let nav = formSheetController.presentedFSViewController as? UINavigationController {
                
                if let archiveVC = nav.topViewController as? ArchiveVC {
                    archiveVC.archiveItem = archiveItem
                    archiveVC.delegate = self
                }
            }
        }
        
        
    }
    
    private func setArchiveStatus(status: ArchiveStatus, atIndexPath indexPath: NSIndexPath ) {
        let archive = archives[indexPath.section][indexPath.row]
        setArchive(archive, status: status)
    }
    
    private func setArchive(archive: Archive, status: ArchiveStatus ) {
        
        archive.archiveStatus = status.rawValue
        archive.archivedAt = NSDate()
        
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait();
        
    }
    
    private func setupIcons() {
        checkIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        closeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        composeIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
        clockIcon.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor())
    }
    
    func insertNewObject(sender: AnyObject) {
        
        /*
        let archive = Archive.MR_createEntity() as Archive;
        archive.archiveStatus = ArchiveStatus.NotSet.rawValue
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        fetchArchives()
        tableView.reloadData()
        */
        
    }
    
    private func fetchArchives() {
        let fetchRequest = Archive.MR_createFetchRequest()
        
        switch self.currentStatus {
        case .NotSet:
            let sortDescriptor = NSSortDescriptor(key: "message.senderDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
        default:
            let sortDescriptor = NSSortDescriptor(key: "archivedAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

        }
        
        let predicate = NSPredicate(format: "archiveStatus == %d", currentStatus.rawValue)
        fetchRequest.predicate = predicate
        
        var archives = Archive.MR_executeFetchRequest(fetchRequest!) as [Archive]
        
        refreshArhives(archives, byTableStyle: self.tableStyle)
        
        println("loaded archives count: \(archives.count)")
        
    }
    
        
    private func refreshArhives(archives: [Archive], byTableStyle tableStyle: TableStyle) {
        
        var groupFunction: (Archive) -> String
        
        switch tableStyle {
        case .Grouped:
            switch self.currentStatus {
            case .NotSet:
                groupFunction = { archive in
                    return archive.message.senderDate.dateStringWithFormat("MMM d")
                }
            default:
                groupFunction = { archive in
                    return archive.archivedAt.dateStringWithFormat("MMM d")
                }

                
            }
        case .Simple:
            groupFunction = { archive in
                return ""
            }
        }
        
        let groupedArchives = grouppingArchives(archives, groupFunction)
        self.sections = groupedArchives.sections
        self.archives = groupedArchives.grouped
        
        self.tableView.reloadData()
    }
    
    private func grouppingArchives(archives: [Archive], groupFunction: (Archive) -> String) -> (sections: [String], grouped: [[Archive]]) {
        var grouped = [[Archive]]()
        var sections = [String]()
        
        for archive in archives {
            
            let sent = groupFunction(archive)
            
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
            println("mailbox fetching  is finished")
        }
        
        let bipoManager = BipoManagerFactory.defaultManager()
        bipoManager.refresh() {
            println("bipo refreshing is finished")
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
    
    //MARK: - SegmentControl Actions
    
    @IBAction func segmentControlDidChange(sender: UISegmentedControl) {
        
        var groupMethod: (Archive) -> String
        switch sender.selectedSegmentIndex {
        case 0:
            self.tableStyle = .Simple
        case 1:
            self.tableStyle = .Grouped
        default:
            return;
        }
        
        var archives = [Archive]()
        for items in self.archives {
            for item in items {
                archives.append(item)
            }
        }
        
        refreshArhives(archives, byTableStyle: self.tableStyle)
        
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

        configureActionsForCell(cell)
        
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
    
    private func configureActionsForCell(cell: SBGestureTableViewCell) {
        
        let size = CGSizeMake(30, 30)
        
        switch (currentStatus) {
        case .Archived:
            
            //reject
            cell.firstLeftAction = SBGestureTableViewCellAction(icon: closeIcon.imageWithSize(size), color: redColor, fraction: 0.3, didTriggerBlock: rejectBlock)
            
            //not set
            cell.firstRightAction = SBGestureTableViewCellAction(icon: composeIcon.imageWithSize(size), color: brownColor, fraction: 0.3, didTriggerBlock: notSetBlock)
            
        case .Rejected:
            
            //archive
            cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkIcon.imageWithSize(size), color: greenColor, fraction: 0.3, didTriggerBlock: archiveBlock)
            
            //not set
            cell.firstRightAction = SBGestureTableViewCellAction(icon: composeIcon.imageWithSize(size), color: brownColor, fraction: 0.3, didTriggerBlock: notSetBlock)
            
        case .NotSet:
            
            //archive
            cell.firstLeftAction = SBGestureTableViewCellAction(icon: checkIcon.imageWithSize(size), color: greenColor, fraction: 0.3, didTriggerBlock: archiveBlock)
            
            //reject
            cell.firstRightAction = SBGestureTableViewCellAction(icon: closeIcon.imageWithSize(size), color: redColor, fraction: 0.3, didTriggerBlock: rejectBlock)
        }

    }
    
    private func configureMessageCell(cell: SBGestureTableViewCell, withMessage message: MailboxMessage?) {
        
        let messageCell = cell as MessageCell
        
//        messageCell.contentLabel?.text = message?.content
        messageCell.subjectLabel?.text = message?.subject
        messageCell.senderDateLabel?.text = message?.senderDate.dateStringWithFormat("MMM d")
        messageCell.senderLabel?.text = "Test@gmail.com"
    }
    
    private func configureTimelineCell(cell: SBGestureTableViewCell, withMessage message: MailboxMessage?) {
        
        let timelineCell = cell as TimelineCell2
        
        
        if let senders = message?.senders {
            for contact in senders.allObjects as [MailboxContact] {
                let monogram = contact.monogram
                timelineCell.profileImageView.image = ImageUtils.imageFromText(monogram)
                break;
            }
        } else {            
            timelineCell.profileImageView.image = UIImage(named: "person")
        }
        
        timelineCell.subjectLabel.text = message?.subject
        timelineCell.dateLabel.text = message?.senderDate.dateStringWithFormat("MMM d")
        timelineCell.nameLabel?.text = "Test@gmail.com"
        timelineCell.contentLabel?.text = "Checking out of the hotel today. It was really fun to see everyone and catch up. We should have more conferences like this so we can share ideas."
    }
    
    
    private func configureArchivedCell(cell: SBGestureTableViewCell, withArchiveItem archived: Archive) {
        
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var identifier = ""
        switch self.currentStatus {
        case .NotSet:
            identifier = "TimelineHeaderCell"
        default:
            identifier = "MessageHeaderCell"
        }
        let  headerCell = tableView.dequeueReusableCellWithIdentifier(identifier) as TimelineHeaderCell
        headerCell.backgroundColor = UIColor.whiteColor()
        headerCell.headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)?
        return headerCell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var identifier = ""
        switch self.currentStatus {
        case .NotSet:
            identifier = "TimelineFooterCell"
        default:
            identifier = "MessageFooterCell"
        }
        
        let  footerView = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        footerView.backgroundColor = UIColor.whiteColor()
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
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
    
    // MARK: - ArchiveVCDelegate 
    
    func archivingDidAccepted(archive: Archive) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    
    func archivingDidCancel(archive: Archive?) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { formSheetController in
            
            if archive != nil {
                self.setArchive(archive!, status: self.currentStatus)
                self.fetchArchives()            }
            
        })
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
        
        profileImageView.layer.cornerRadius = 27
        
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


class TimelineHeaderCell: UITableViewCell {
    
    @IBOutlet var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}