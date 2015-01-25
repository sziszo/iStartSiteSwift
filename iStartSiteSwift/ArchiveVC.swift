//
//  ArchiveVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 22..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import UIKit

protocol ArchiveVCDelegate {
    
    func archivingDidAccepted(archive: Archive)
    func archivingDidCancel(archive: Archive?)
    
}

class ArchiveVC: UITableViewController {
    
    var archiveItem: Archive?
    
    private var items = [ArchiveInfo]();
    private let searchIcon = FAKIonIcons.iosSearchIconWithSize(30)
    
    var delegate: ArchiveVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [ArchiveInfo(category: ArchiveInfoCategory.Company, label: "Company"),
            ArchiveInfo(category: ArchiveInfoCategory.Person, label: "Person"),
            ArchiveInfo(category: ArchiveInfoCategory.Order, label: "Order")]
        
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        
        cell.textLabel?.text = items[indexPath.row].label
        //        cell.detailTextLabel?.text = items[indexPath.row].value
        cell.detailTextLabel?.text = "Subtitle #\(indexPath.row)"
        
        cell.accessoryView = UIImageView(image: searchIcon.imageWithSize(CGSize(width: 30, height: 30)))
        cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("archiveSearch", sender: tableView)
    }
    
    // MARK - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "archiveSearch" {
            let reportVC = segue.destinationViewController as ReportVC
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let destinationTitle = self.items[indexPath.row].label
            reportVC.title = destinationTitle
//            reportVC.historyItems = 
            
            var reportItems = [ReportItem]()
            let companies = Company.MR_findAll() as [Company]
            for company in companies {
                reportItems += [ReportItem(id: company.companyId.integerValue, name: company.formattedCompanyName())]
            }
            reportVC.reportItems = reportItems

            
        }
    }
    
    @IBAction func returnToArchive(segue: UIStoryboardSegue?) {
        println("return to archive")
        if segue?.identifier == "returnToArchive" {
            let reportVC = segue?.sourceViewController as ReportVC
            if let selectedReportItem = reportVC.selectedReportItem {
                println("selected Item name is \(selectedReportItem.name) ")
                
                //TODO update the field with selected item
            }
        }
    }
    
    @IBAction func saveButtonTouched(sender: UIBarButtonItem) {
        if self.archiveItem != nil {
            delegate?.archivingDidAccepted(self.archiveItem!)
        }
    }
    
    @IBAction func cancelButtonTouched(sender: UIBarButtonItem) {
        delegate?.archivingDidCancel(self.archiveItem)
    }
}
