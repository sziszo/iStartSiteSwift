//
//  MessageDetailVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 26..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import UIKit

class MessageDetailVC: UIViewController {

    @IBOutlet weak var subjectLable: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var sentDateLabel: UILabel!
    @IBOutlet weak var contentView: UIWebView!
    
    var message: MailboxMessage!
    
    let checkIcon = FAKIonIcons.iosCheckmarkIconWithSize(30)
    let closeIcon = FAKIonIcons.iosCloseIconWithSize(30)
    let composeIcon = FAKIonIcons.iosComposeIconWithSize(30)
    let clockIcon = FAKIonIcons.iosClockIconWithSize(30)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let size = CGSize(width: 30.0, height: 30.0)
        
        let composeButton = UIBarButtonItem(image: composeIcon.imageWithSize(size), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        let closeButton = UIBarButtonItem(image: closeIcon.imageWithSize(size), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        let checkButton = UIBarButtonItem(image: checkIcon.imageWithSize(size), style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        
        self.navigationItem.rightBarButtonItems = [checkButton, closeButton, composeButton]
        
        
        subjectLable.text = message.subject
        senderLabel.text = message.toStringSenders()
        sentDateLabel.text = message.senderDate.dateStringWithFormat("MMM d")
        contentView.loadHTMLString(message.content, baseURL: nil)
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

}
