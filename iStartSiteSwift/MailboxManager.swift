//
//  MailboxManager.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 14..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import Foundation

class MailboxManager {
    
    var account: Mailbox
    var imapSession: MCOIMAPSession
    
    var runningTasks: Int = 0
    
    init(account: Mailbox) {
        self.account = account
        
        println(" login: \(account.loginName)")
        
        imapSession = MCOIMAPSession()
        imapSession.hostname = account.server
        imapSession.port = account.port.unsignedIntValue
        imapSession.username = account.loginName
        imapSession.password = account.password
        imapSession.connectionType = MCOConnectionType.TLS
    }
    
    
    func fetchMessages(complete: () -> ()) {
        
        var folders = [MailboxFolder]()
        
        
        var fetchOperation: MCOIMAPFetchFoldersOperation = imapSession.fetchSubscribedFoldersOperation()
        
        fetchOperation.start({error, folders in
            
            if (error != nil) {
                println("Error downloading message headers: \(error)")
                return
            }
            
            //foldernames
            var folderNames = [String]()
            for imapFolder in folders as [MCOIMAPFolder] {
                folderNames.append(imapFolder.path)
            }
            
            //filter folder names
            let predicate = NSPredicate(format: "NOT( SELF BEGINSWITH[cd] %@ )", "[Gmail]")!
            let filteredFolderNames = folderNames.filter() { predicate.evaluateWithObject($0) }
            
            //save folders
            MagicalRecord.saveWithBlock({ localContext in
                
                if let mailbox = Mailbox.MR_findFirstByAttribute("loginName", withValue: self.account.loginName, inContext: localContext) as? Mailbox {
                    
                    for folderName in filteredFolderNames {
                        
                        var mailboxFolder = MailboxFolder.MR_findFirstByAttribute("name", withValue: folderName, inContext: localContext) as? MailboxFolder
                        if mailboxFolder == nil {
                            mailboxFolder = MailboxFolder.MR_createInContext(localContext) as MailboxFolder!
                            mailboxFolder?.name = folderName
                        }
                        mailbox.addFolder(mailboxFolder!)
                        
                    }
                    
                }
                
                
                }, completion: { success, error in
                    
                    if let mailbox = Mailbox.MR_findFirstByAttribute("loginName", withValue: self.account.loginName) as? Mailbox {
                        
                        self.runningTasks = mailbox.folders.count
                        for folder in mailbox.folders {
                            self.fetchMessagesInFolder(folder.name, complete)
                        }
                    }
            })
        })
        
        
        
    }
    
    func fetchMessagesInFolder(folderName: String, complete: () -> ()) {
        
        
        //FETCH REQUEST
        var requestKind: MCOIMAPMessagesRequestKind = .Headers
        var uids: MCOIndexSet = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
        
        var fetchOperation: MCOIMAPFetchMessagesOperation = imapSession.fetchMessagesOperationWithFolder(folderName, requestKind: requestKind, uids: uids)
        
        fetchOperation.start() { error, fetchedMessages, vanishedMessages in
            
            if (error != nil) {
                println("Error downloading message headers: \(error)")
                return
            }
            
            
            MagicalRecord.saveWithBlock({ localContext in
                
                if let folder = MailboxFolder.MR_findFirstByAttribute("name", withValue: folderName, inContext: localContext) as? MailboxFolder {
                    
                    
                    for mail in fetchedMessages as [MCOIMAPMessage] {
                        
                        var message = MailboxMessage.MR_findFirstByAttribute("uid", withValue: NSNumber(unsignedInt: mail.uid), inContext: localContext ) as? MailboxMessage
                        if message == nil {
                            
                            //NEW MESSAGE
                            message = self.createMessageFromMail(mail, inContext: localContext)
                            message?.folder = folder
                            
                            println("donwloaded message: id=\(message?.uid)")
                            
                        } else {
                            
//                            println("message has already been downloaded! uid = \(mail.uid)")
                            
                        }
                        
                        //archive message
//                        self.archiveIncomingMessage(message!, inContext: localContext)
                    }
                    
                }
                
                
                
                }, completion: { success, error in
                    
                    self.fetchMessagesContentInFolder(folderName) {
                        if --self.runningTasks == 0 {
                            complete()
                        }
                    }
            })
            
        }
    }
    
    
    func createMessageFromMail(mail: MCOIMAPMessage, inContext localContext: NSManagedObjectContext!) -> MailboxMessage {
        
        let header = mail.header
        
        let message = MailboxMessage.MR_createInContext(localContext) as MailboxMessage!
        message.uid = NSNumber(unsignedInt: mail.uid)
        message.subject = header.subject
        message.senderDate = header.receivedDate
        
        
        //helper function
        func findContactFromAddress(address:MCOAddress) -> MailboxContact {
            var contact = MailboxContact.MR_findFirstByAttribute("emailAddress", withValue: address.mailbox, inContext: localContext) as? MailboxContact
            if contact == nil {
                
                contact = MailboxContact.MR_createInContext(localContext) as MailboxContact!
                contact?.emailAddress = address.mailbox
                if let displayName = address.displayName {
                    contact?.displayName = displayName
                }
                
            }
            return contact!
        }
        
        //FROM
        let from = findContactFromAddress(header.from)
        from.addSentMessage(message)
        
        //TO
        if let to = header.to as? [MCOAddress] {
            for receiver in to {
                
                let contact = findContactFromAddress(receiver)
                contact.addReceivedMessage(message)
                
            }
        }
        
        //CC
        if let cc = header.cc as? [MCOAddress] {
            for receiver in cc  {
                
                let contact = findContactFromAddress(receiver)
                contact.addReceivedMessage(message)
                
            }
        }
        
        //BCC
        if let bcc = header.bcc as? [MCOAddress] {
            for receiver in bcc {
                
                let contact = findContactFromAddress(receiver)
                contact.addReceivedMessage(message)
                
            }
        }
        
        return message
        
    }
    
    var runningOperation = 0
    
    func fetchMessagesContentInFolder(folderName: String, complete: () -> ()) {
        
        let contextForCurrentThread = NSManagedObjectContext.MR_contextForCurrentThread()
        
        if let folder = MailboxFolder.MR_findFirstByAttribute("name", withValue: folderName, inContext: contextForCurrentThread) as? MailboxFolder {
            
            
            for message in folder.messages.allObjects as [MailboxMessage] {
                
                let uid = message.uid

                if let content = message.content {
                    if !content.isEmpty {
                        println("content exists (uid:\(uid))")
                        self.archiveIncomingMessage(message, inContext: contextForCurrentThread)
                        continue
                    }
                }
                
                println("starting fetching body of the email with uid \(message.uid)")
                self.runningOperation++
                
                var fetchContentOperation = self.imapSession.fetchMessageOperationWithFolder(folderName, uid: message.uid.unsignedIntValue, urgent: true) as MCOIMAPFetchContentOperation
                
                
                fetchContentOperation.start() {
                    error, data in
                    
                    if error != nil {
                        println("An error occred while fetching the content of the email (ui:\(uid))! error: \(error.localizedDescription)")
                    }
                    
                    let parser = MCOMessageParser(data: data)
                    let plainTextBody = parser.plainTextBodyRendering()
                    
                    MagicalRecord.saveWithBlock({ localContext in
                        
                        if let message = MailboxMessage.MR_findFirstByAttribute("uid", withValue: uid, inContext: localContext) as? MailboxMessage {
                            
                            message.content = plainTextBody
                            
                            self.archiveIncomingMessage(message, inContext: localContext)
                        }
                        
                        
                        }) {
                            succcess, error in
                            
                            if --self.runningOperation == 0 {
                                self.runningOperation = -1
                                complete()
                            }
                            
                    }
                }
            }

            contextForCurrentThread.MR_saveToPersistentStoreAndWait()
            if self.runningOperation == 0 {
                println("fire completion after saved data")
                complete()
            }
            
        }
        
        
        
    }
    
    
    
    
    func archiveIncomingMessage(message: MailboxMessage, inContext localContext: NSManagedObjectContext!) {
        
        var archive: Archive? = message.archiveInfo
        if archive == nil {
            archive = Archive.MR_createInContext(localContext) as Archive!
            archive?.message = message
            archive?.archiveStatus = NSNumber(integer: ArchiveStatus.NotSet.rawValue)
            archive?.archivedAt = NSDate()
            //TODO set archive.creator to current user
        }
        
        let archiveStatus = ArchiveStatus(rawValue: archive?.archiveStatus as Int)
        if archiveStatus == ArchiveStatus.NotSet {
            
            
            func loadContactFromMailboxContact(mailboxContact: MailboxContact) -> Contact? {
                
                var contact: Contact? = mailboxContact.contact;
                
                if contact == nil {
                    
                    //println("Searching bipo contact for sender \(mailboxContact.toString())")
                    //                    println("Searching bipo contact for uid \(message.uid)")
                    if let contactEmail = ContactEmail.MR_findFirstByAttribute("email", withValue: mailboxContact.emailAddress, inContext: localContext) as? ContactEmail {
                        contact = contactEmail.contact
                        mailboxContact.contact = contact!
                        //println("found bipo contact for sender \(mailboxContact.toString())")
                    }
                }
                
                return contact
            }
            
            
            for sender in message.senders {
                
                if let contact = loadContactFromMailboxContact(sender as MailboxContact) {
                    
                    var employee: Employee? = contact.employee
                    let person: Person? = contact.person
                    if employee == nil && person != nil {
                        if let employees = person?.employes.allObjects as? [Employee] {
                            employee = employees[0]
                        }
                    }
                    
                    if employee != nil {
                        archive?.company = employee!.company
                        archive?.employee = employee!
                    } else {
                        archive?.company = contact.company
                    }
                    
                }
            }
            
            //TODO looking for the project number in the message subject ( and in the message body )
            
            
        }
        
        
    }
    
    
    // MARK: Unwind
    
    @IBAction func unwindToMailbox(segue: UIStoryboardSegue) {
    }
    
    
}