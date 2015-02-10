//
//  TableViewController.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 10..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

import UIKit


enum OperationType {
    case ArchiveMessage(ArchiveStatus)
    case PerformingTask(TaskStatus)
}

enum TaskStatus: Int  {
    case NotSet = 0, Done, Rejected
}


class MailboxVC: UITableViewController, UITableViewDataSource, UITableViewDelegate, MenuViewControllerDelegate, CenterViewController, ArchiveVCDelegate, MessageDetailVCDelegate {
    
    struct Constants {
        struct Seque {
            static let showMessageDetail = "showMessageDetail"
            static let showTimelineMessageDetail = "showTimelineMessageDetail"
        }
        
        struct TableViewCell {
            static let TimelineCell = ""
            static let MessageCell = ""
            static let ArchiveCell = ""
        }
    }
    
    
    private enum OperationManager {
        case ArchiveManager(ArchiveMessageManager)
//        case TaskOperationManager()
    }
    
    private var operationManager: OperationManager = .ArchiveManager(ArchiveMessageManager())
    private var operationType: OperationType = .ArchiveMessage(.NotSet) {
        willSet(newOperationType) {
            
            switch newOperationType {
            case .ArchiveMessage(let newStatus):
                switch self.operationType {
                case .ArchiveMessage(let oldStatus):
                    if newStatus == oldStatus {
                        return
                    }
                default:
                    break
                }
            case .PerformingTask(let newStatus):
                switch self.operationType {
                case .PerformingTask(let oldStatus):
                    if newStatus == oldStatus {
                        return
                    }
                default:
                    break
                }
                
            }
            
            switch newOperationType {
            case .ArchiveMessage(_):
                operationManager = .ArchiveManager(ArchiveMessageManager())
            default:
                break
            }
            
        }
    }
    
    
//    private var tableStyle: TableStyle = .Grouped
    
    @IBOutlet weak var sbgTableView: SBGestureTableView!
    
    let menuIcon = FAKIonIcons.androidMenuIconWithSize(30)
    let checkIcon = FAKIonIcons.iosCheckmarkIconWithSize(30)
    let closeIcon = FAKIonIcons.iosCloseIconWithSize(30)
    let composeIcon = FAKIonIcons.iosComposeIconWithSize(30)
    let clockIcon = FAKIonIcons.iosClockIconWithSize(30)
    let greenColor = Appearance.TableCell.actionColorGreen //UIColor(red: 85.0/255, green: 213.0/255, blue: 80.0/255, alpha: 1)
    let redColor = Appearance.TableCell.actionColorRed //UIColor(red: 213.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1)
    let yellowColor = UIColor(red: 236.0/255, green: 223.0/255, blue: 60.0/255, alpha: 1)
    let brownColor = UIColor(red: 182.0/255, green: 127.0/255, blue: 78.0/255, alpha: 1)
    
    private var archiveBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    private var rejectBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    private var notSetBlock: ((SBGestureTableView, SBGestureTableViewCell) -> Void)!
    
    var delegate: CenterViewControllerDelegate?
    
    var zoomPresentAnimationController: ZoomPresentAnimationController!
    var zoomDismissAnimationController: ZoomDismissAnimationController!
    
    var selectedIndexPath: NSIndexPath?
    var removeSelectedCellWhenViewWillAppear = false

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoomPresentAnimationController = ZoomPresentAnimationController()
        zoomDismissAnimationController = ZoomDismissAnimationController()
        
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor(red: 209, green: 238, blue: 252, alpha: 1)
        
        sbgTableView = self.tableView as SBGestureTableView;
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "insertNewObject:")
        navigationItem.rightBarButtonItem = addButton
        
        let size = CGSizeMake(30, 30)
        self.navigationItem.leftBarButtonItem?.title = ""
        self.navigationItem.leftBarButtonItem?.image = menuIcon.imageWithSize(size)
        
        setupIcons()
        
        
        
        archiveBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Archive item at \(indexPath)")
            
            switch self.operationManager {
            case .ArchiveManager(let manager):
                //update ArchiveStatus
                manager.setArchiveStatus(ArchiveStatus.Archived, atIndexPath: indexPath!, withDate: false)
            }
            
//            let archiveItem = self.archives[indexPath!.section][indexPath!.row]
            
            switch self.operationManager {
            case .ArchiveManager(let manager):
                
                let archiveItem = manager.data[indexPath!.section].value[indexPath!.row]
            
                self.removeTableView(tableView, cell: cell, atIndexPath: indexPath!)
                self.showArchiveVC(archiveItem)
            }
            
            
        }

        rejectBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Reject item at \(indexPath)")
            
            switch self.operationManager {
            case .ArchiveManager(let manager):
                //update ArchiveStatus
                manager.setArchiveStatus(ArchiveStatus.Rejected, atIndexPath: indexPath!)
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait();
            }

            //remove cell
            self.removeTableView(tableView, cell: cell, atIndexPath: indexPath!)
            
        }
        
        notSetBlock = {(tableView: SBGestureTableView, cell: SBGestureTableViewCell) -> Void in
            
            let indexPath = tableView.indexPathForCell(cell)
            println("Set item's status at \(indexPath) to NotSet")
            
            switch self.operationManager {
            case .ArchiveManager(let manager):
                //update ArchiveStatus
                manager.setArchiveStatus(ArchiveStatus.NotSet, atIndexPath: indexPath!)
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait();
            }
            

            //remove cell
            self.removeTableView(tableView, cell: cell, atIndexPath: indexPath!)

        }

        
        fetchData()
        
        //setup refreshcontrol
        initRefreshControl()
    }
    
    private func fetchData() {
        
        //fetch data
        
        switch operationManager {
        case .ArchiveManager(let manager):
            manager.fetch(operationType) { self.tableView.reloadData() }
            
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        if self.removeSelectedCellWhenViewWillAppear {
            if let indexPath = self.selectedIndexPath {
                let cell = sbgTableView.cellForRowAtIndexPath(indexPath) as SBGestureTableViewCell
                self.removeTableView(self.sbgTableView, cell:cell, atIndexPath:  indexPath)
            }
            self.removeSelectedCellWhenViewWillAppear = false
        }
        println("viewDidAppear")
    }
    
    private func removeTableView(tableView: SBGestureTableView, cell: SBGestureTableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        switch operationManager {
        case .ArchiveManager(let manager):
            manager.removeArchiveAtIndexPath(indexPath)
            
            tableView.removeCell(cell, duration: 0.3) {
                
                if manager.data[indexPath.section].value.count == 0 {
                    manager.removeKeyAtIndexPath(indexPath)
                }
                
                tableView.reloadData()
                
            }
        }
        
    }
    
    private func showArchiveVC(archiveItem: Archive) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("archiveNavVC") as UINavigationController;
        if let archiveVC = vc.topViewController as? ArchiveVC {
            if archiveItem.company == nil {
                if let company = HistoryManager.defaultManager.lastSelectedCompany {
                    archiveItem.company = company
                }
            }
            if archiveItem.employee == nil {
                if let employee = HistoryManager.defaultManager.lastSelectedEmployee {
                    archiveItem.employee = employee
                }
            }
            archiveVC.archiveItem = archiveItem
            archiveVC.delegate = self
        }
        
        
        
        
        let formSheetController = MZFormSheetController(viewController: vc)
//        formSheetController.shouldDismissOnBackgroundViewTap = true
        self.mz_presentFormSheetController(formSheetController, animated: true) { formSheetController in
            println("form sheet is displayed!")
        }
        
        
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
            self.fetchData()
            println("mailbox fetching  is finished")
        }
        
        let bipoManager = BipoManagerFactory.defaultManager()
        bipoManager.refresh() {
            println("bipo refreshing is finished")
        }

        Timer.start(3, repeats: false) {
            
            self.refreshControl?.endRefreshing()
            
            let lastUpdated = NSDate().dateStringWithFormat("MMM d, h:mm:ss")
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refersh! Last updated on \(lastUpdated)")
            
            
            self.tableView.reloadData()

            println("end refreshing")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == Constants.Seque.showMessageDetail || segue.identifier == Constants.Seque.showTimelineMessageDetail {
            if let indexPath = tableView.indexPathForSelectedRow() {
                
                switch operationManager {
                case .ArchiveManager(let manager):
                
                    let archive = manager.data[indexPath.section].value[indexPath.row]
                    let messageDetailVC = segue.destinationViewController as MessageDetailVC
                    messageDetailVC.message = archive.message
                    messageDetailVC.delegate = self
                    messageDetailVC.title = "Message"
                    
                }

                
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)

            }
        }

        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let point = touch.locationInView(self.view)
    }
    
    // MARK: Unwind
    @IBAction func returnToMailbox(segue: UIStoryboardSegue?) {
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch operationManager {
        case .ArchiveManager(let manager):
            return manager.data.count
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch operationManager {
        case .ArchiveManager(let manager):
            return manager.data[section].value.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier = ""
        
        
        switch operationType {
        case .ArchiveMessage(let archiveStatus):
            switch archiveStatus {
            case .Archived:
                cellIdentifier = "ArchiveCell"
            case .NotSet:
                cellIdentifier = "TimelineCell"
            default:
                cellIdentifier = "MessageCell"
            }
        case .PerformingTask(let taskStatus):
            break
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as SBGestureTableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
        
    }
    
    func configureCell(cell: SBGestureTableViewCell, atIndexPath indexPath: NSIndexPath ) {

        configureActionsForCell(cell)
        
        switch operationManager {
        case .ArchiveManager(let manager):
            
            let archive = manager.data[indexPath.section].value[indexPath.row]
            
            switch operationType {
            case .ArchiveMessage(let archiveStatus):
                switch (archiveStatus) {
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
            default:
                break
            }
            
        }
        
    }
    
    private func configureActionsForCell(cell: SBGestureTableViewCell) {
        
        let size = CGSizeMake(30, 30)
        
        switch operationType {
        case .ArchiveMessage(let archiveStatus):
            switch (archiveStatus) {
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
            
        case .PerformingTask(let taskStatus):
            break
            
        }

    }
    
    private func configureMessageCell(cell: SBGestureTableViewCell, withMessage message: MailboxMessage?) {
        
        let messageCell = cell as MessageCell
        
        messageCell.contentLabel?.text = message?.shortContent(size: 256)
        messageCell.subjectLabel?.text = message?.subject
        messageCell.senderDateLabel?.text = message?.senderDate.dateStringWithFormat("MMM d HH:mm")
        messageCell.senderLabel?.text = message?.toStringSenders()
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
        timelineCell.dateLabel.text = message?.senderDate.dateStringWithFormat("MMM d HH:mm")
        timelineCell.nameLabel?.text = message?.toStringSenders()
        
        if UIDevice.currentDevice().orientation.isLandscape {
            timelineCell.contentLabel?.text = message?.shortContent(size: 256)
        } else {
            timelineCell.contentLabel?.text = message?.shortContent()
        }
        
        timelineCell.backgroundColor = Appearance.TableCell.backgroundColor
        
    }
    
    
    private func configureArchivedCell(cell: SBGestureTableViewCell, withArchiveItem archived: Archive) {
        
        func getFormattedCompany() -> String {
            let company: Company? = archived.company
            return company != nil ? company!.formattedCompanyName() : "Unknown company"
        }
        
        func getFormattedPerson() -> String {
            let person: Person? = archived.employee?.person
            return person != nil ? person!.formattedPersonName() : "Unknown person"
        }
        
        func getFormattedOrder() -> String {
            return "Unknown order"
        }
        
        let archivedCell = cell as ArchivedCell
        archivedCell.companyLabel?.text = getFormattedCompany()
        archivedCell.personLabel?.text = getFormattedPerson()
        archivedCell.orderNrLabel?.text = getFormattedOrder()
        archivedCell.archivedAtLabel?.text = archived.archivedAt.dateStringWithFormat("MMM d HH:mm")
        
        let message = archived.message;
        archivedCell.subjectLabel?.text = message.subject;
    }
    
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch operationManager {
        case .ArchiveManager(let manager):
            return manager.data.array[section]
        }
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var identifier = ""
        switch operationType {
        case .ArchiveMessage(let archiveStatus):
            
            switch archiveStatus {
            case .NotSet:
                identifier = "TimelineHeaderCell"
            default:
                identifier = "MessageHeaderCell"
            }
            
        case .PerformingTask(let taskStatus):
            break
        }
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier(identifier) as TimelineHeaderCell
        headerCell.backgroundColor = Appearance.TableHeader.backgroundColor
        headerCell.headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)?
        return headerCell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var identifier = ""
        switch operationType {
        case .ArchiveMessage(let archiveStatus):
            
            switch archiveStatus {
            case .NotSet:
                identifier = "TimelineFooterCell"
            default:
                identifier = "MessageFooterCell"
            }
            
        case .PerformingTask(let taskStatus):
            break
        }
        
        let  footerView = tableView.dequeueReusableCellWithIdentifier(identifier) as UITableViewCell
        footerView.backgroundColor = Appearance.TableFooter.backgroundColor
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            println("landscape")
        } else {
            println("portraight")
        }
        self.tableView.reloadData()
    }

    // MARK: MenuVIewController
    
    func menuSelected(operationType: OperationType) {
        self.operationType = operationType
        
        fetchData()
        
        var title = ""
        switch self.operationType {
        case .ArchiveMessage(let archiveStatus):
            switch archiveStatus {
            case .Archived: title = "Archived"
            case .NotSet: title = "Inbox"
            case .Rejected: title = "Rejected"
            }
        case .PerformingTask(let taskStatus):
            title = "Tasks"
        }
        
        self.title = title

        
        delegate?.collapseSidePanels?()
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
    
    // MARK: - ArchiveVCDelegate 
    
    
    func archivingDidAccepted(archive: Archive) {
        
        HistoryManager.defaultManager.lastSelectedCompany = archive.company
        HistoryManager.defaultManager.lastSelectedEmployee = archive.employee
                
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    
    func archivingDidCancel(archive: Archive?) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { formSheetController in
            
            if archive != nil {
//                NSManagedObjectContext.MR_defaultContext().undo()
                
                switch self.operationManager {
                case .ArchiveManager(let manager):
                    switch self.operationType {
                    case .ArchiveMessage(let archiveStatus):
                        manager.setArchive(archive!, status: archiveStatus, withDate: false)
                        self.fetchData()
                    default:
                        break
                    }
                }
            }
            
        })
    }
    
    // MARK: - MessageDetailVCDelegate
    
    func archiveStatusChanged(archive: Archive) {
        self.removeSelectedCellWhenViewWillAppear = true
            
//        fetchArchives()
//        self.performSegueWithIdentifier(Constants.Seque.showTimelineMessageDetail, sender: tableView)
        
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MessageDetailVC") as MessageDetailVC;
//        vc.message = self.message
//        self.navigationController?.pushViewController(vc, animated: true)
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
        profileImageView.backgroundColor = Appearance.ProfileImage.backgroundColor
        
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