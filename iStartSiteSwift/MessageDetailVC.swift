//
//  MessageDetailVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 26..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import UIKit


protocol MessageDetailVCDelegate {
    
    func archiveStatusChanged(archive: Archive)
}


class MessageDetailVC: UIViewController, ArchiveVCDelegate {

    @IBOutlet weak var subjectLable: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var sentDateLabel: UILabel!
    @IBOutlet weak var contentView: UIWebView!
    
    var message: MailboxMessage!
    var currentStatus: ArchiveStatus = ArchiveStatus.NotSet
    
    var delegate: MessageDetailVCDelegate?
    
//    let defaultBackgroundColor = MP_HEX_RGB("E0F8D8")
//    let defaultBackgroundColor = UIColor.whiteColor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Appearance.MessageView.backgroundColor

        // Do any additional setup after loading the view.
        
        if let archiveStatus = ArchiveStatus(rawValue: message.archiveInfo.archiveStatus.integerValue) {
            self.currentStatus = archiveStatus
        }
        
        let size = CGSize(width: 30.0, height: 30.0)
        let checkIcon = FAKIonIcons.iosCheckmarkIconWithSize(30)
        let closeIcon = FAKIonIcons.iosCloseIconWithSize(30)
        let composeIcon = FAKIonIcons.iosComposeIconWithSize(30)
        let clockIcon = FAKIonIcons.iosClockIconWithSize(30)

        let composeButton = UIBarButtonItem(image: composeIcon.imageWithSize(size), style: UIBarButtonItemStyle.Bordered, target: self, action: "composeButtonTouched:")
        
        let closeButton = UIBarButtonItem(image: closeIcon.imageWithSize(size), style: UIBarButtonItemStyle.Bordered, target: self, action: "closeButtonTouched:")
        
        let checkButton = UIBarButtonItem(image: checkIcon.imageWithSize(size), style: UIBarButtonItemStyle.Bordered, target: self, action: "checkButtonTouched:")

        var rightBarButtons = [UIBarButtonItem]()
        switch currentStatus {
        case .NotSet:
            rightBarButtons = [checkButton, closeButton]
            break
        case .Rejected:
            rightBarButtons = [checkButton, composeButton]
            break
        default:
            break
        }
        
        self.navigationItem.rightBarButtonItems = rightBarButtons
        
        
        subjectLable.text = message.subject
        senderLabel.text = message.toStringSenders()
        sentDateLabel.text = message.senderDate.dateStringWithFormat("MMM d")
        contentView.loadHTMLString(message.contentHtml, baseURL: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            println("landscape")
        } else {
            println("portraight")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - ArchiveVCDelegate
    
    
    func archivingDidAccepted(archive: Archive) {
        
        HistoryManager.defaultManager.lastSelectedCompany = archive.company
        HistoryManager.defaultManager.lastSelectedEmployee = archive.employee
        
        setArchiveStatusAndSave(ArchiveStatus.Archived)

        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { formSheetController in
            self.delegate?.archiveStatusChanged(archive)
            self.dismissVC()
        })
        
    }
    
    func dismissVC() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func archivingDidCancel(archive: Archive?) {
        if archive != nil {
            NSManagedObjectContext.MR_defaultContext().undo()
        }

        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { formSheetController in
        })
    }
    
    // MARK: Actions
    
    func composeButtonTouched(sender: AnyObject) {
        setArchiveStatusAndSave(ArchiveStatus.NotSet)
        self.delegate?.archiveStatusChanged(self.message.archiveInfo)
        self.dismissVC()
    }
    
    func checkButtonTouched(sender: AnyObject) {
        
        showArchiveVC(message.archiveInfo)
        
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MessageDetailVC") as MessageDetailVC;
//        vc.message = self.message
//        
//        self.navigationController!.pushViewController(vc, animated: true)
//        delegate?.archiveItem(self.message.archiveInfo)
        
    }
    
    func closeButtonTouched(sender: AnyObject) {
        setArchiveStatusAndSave(ArchiveStatus.Rejected)
        self.delegate?.archiveStatusChanged(self.message.archiveInfo)
        self.dismissVC()
    }
    
    func setArchiveStatusAndSave(status: ArchiveStatus) {
        self.message.archiveInfo.archiveStatus = status.rawValue
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
    }
    
    private func showArchiveVC(archiveItem: Archive) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("archiveNavVC") as UINavigationController
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
        formSheetController.shouldDismissOnBackgroundViewTap = true
        
        self.mz_presentFormSheetController(formSheetController, animated: true) { formSheetController in
            println("form sheet is displayed!")
        }
        
        
    }


}
