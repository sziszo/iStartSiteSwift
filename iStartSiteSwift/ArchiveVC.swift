//
//  ArchiveVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 22..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//

import UIKit

enum ArchiveInfoCategory: Int {
    case Company = 0, Person, Order
}

struct ArchiveInfo {
    var category: ArchiveInfoCategory
    var label = ""
    var value = ""
    var valid = false;
}

protocol ArchiveVCDelegate {
    
    func archivingDidAccepted(archive: Archive)
    func archivingDidCancel(archive: Archive?)
    
}

class ArchiveVC: UITableViewController {
    
    struct Constants {
        
        struct TableViewCell {
            static let name = "Cell"
        }
        
        static let undefinedValue = "Undefined"
    }
    
    var archiveItem: Archive?
    
    private var items = [ArchiveInfo]();
    private let searchIcon = FAKIonIcons.iosSearchIconWithSize(30)
    
    var delegate: ArchiveVCDelegate?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var companyValue = Constants.undefinedValue
        var personValue = Constants.undefinedValue
        var orderValue = Constants.undefinedValue
        if self.archiveItem != nil {
            
            if let company = archiveItem!.company {
                companyValue = company.formattedCompanyName()
            }
            if companyValue.isEmpty {
                companyValue = Constants.undefinedValue
            }
            
            if let employee = archiveItem!.employee {
                personValue = employee.person.formattedPersonName()
            }
            if personValue.isEmpty {
                personValue = Constants.undefinedValue
            }
            
            //TODO fill orderValue
        }
        
        
        let companyRow = ArchiveInfo(category: ArchiveInfoCategory.Company, label: "Company", value: companyValue, valid: self.validateCompany())
        let personRow = ArchiveInfo(category: ArchiveInfoCategory.Person, label: "Person", value: personValue, valid: self.validatePerson())
        let orderRow = ArchiveInfo(category: ArchiveInfoCategory.Order, label: "Order", value: orderValue, valid: true)
        
        items = [companyRow, personRow, orderRow]
        
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.name, forIndexPath: indexPath) as UITableViewCell
        
        let item = items[indexPath.row]
        println("item-label: \(item.label), item-value: \(item.value)")
        
        //letterpress label
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let textColor = UIColor(red: 0.175, green: 0.458, blue: 0.831, alpha: 1)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            NSTextEffectAttributeName : NSTextEffectLetterpressStyle
        ]
        let letterpressItemLable = NSAttributedString(string: item.label, attributes: attributes)
        
        cell.textLabel?.attributedText = letterpressItemLable
        cell.detailTextLabel?.text = item.value
        
        if !item.valid {
            cell.backgroundColor = UIColor.orangeColor()
            cell.detailTextLabel?.textColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        }
        
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
            let selectedItem = self.items[indexPath.row]
            
            //title
            let destinationTitle = selectedItem.label
            reportVC.title = destinationTitle
            
            //category
            let category = selectedItem.category
            reportVC.category = category
            
//            reportVC.historyItems = 
            
            var reportItems = [ReportItem]()
            switch category {
            case .Company:
                let companies = Company.MR_findAll() as [Company]
                for company in companies {
                    println("\(company.companyId.integerValue) \(company.formattedCompanyName())")
                    
                    reportItems += [ReportItem(id: company.companyId.integerValue, name: company.formattedCompanyName())]
                }
            case .Person:
                if let company = archiveItem?.company {
                    println("\(company.companyId.integerValue) \(company.formattedCompanyName())")
                    let employees = Employee.MR_findByAttribute("company", withValue: company) as [Employee]
                    for employee in employees {
                        reportItems += [ReportItem(id: employee.employeeId.integerValue, name: employee.person.formattedPersonName())]
                    }
                }
                
            case .Order:
                break;
            }
            
            reportVC.reportItems = reportItems
            reportVC.historyItems = reportItems
            
        }
    }
    
    @IBAction func returnToArchive(segue: UIStoryboardSegue?) {
        println("return to archive")
        if segue?.identifier == "returnToArchive" {
            let reportVC = segue?.sourceViewController as ReportVC
            if let selectedReportItem = reportVC.selectedReportItem {
                println("selected Item name is \(selectedReportItem.name) ")
                
                if let category = reportVC.category {
                    switch category {
                    case .Company:
                        println("returnToArchive = \(selectedReportItem.id)")
                        if let company = Company.MR_findFirstByAttribute("companyId", withValue: selectedReportItem.id) as? Company {
                            self.archiveItem?.company = company
                            
                            self.items[ArchiveInfoCategory.Company.rawValue].value = company.formattedCompanyName()
                            self.items[ArchiveInfoCategory.Company.rawValue].valid = self.validateCompany()
                            self.items[ArchiveInfoCategory.Person.rawValue].valid = self.validatePerson()

                            //TODO validate current Person and Order values
                            
                            self.tableView.reloadData()
                            
                        }
                    case .Person:
                        if let employee = Employee.MR_findFirstByAttribute("employeeId", withValue: selectedReportItem.id) as? Employee {
                            self.archiveItem?.employee = employee
                            self.items[ArchiveInfoCategory.Person.rawValue].value = employee.person.formattedPersonName()
                            self.items[ArchiveInfoCategory.Person.rawValue].valid = self.validatePerson()
                            
                            //TODO validate current Order values
                            
                            self.tableView.reloadData()
                        }
                    default:
                        break
                    }
                }
                //TODO update the field with selected item
            }
        }
    }
    
    @IBAction func saveButtonTouched(sender: UIBarButtonItem) {
        if self.archiveItem != nil {
            
            //TODO validate cmopany, person and order
            
            self.archiveItem!.archivedAt = NSDate()
            NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait();
            
            delegate?.archivingDidAccepted(self.archiveItem!)
        }
    }
    
    @IBAction func cancelButtonTouched(sender: UIBarButtonItem) {
        delegate?.archivingDidCancel(self.archiveItem)
    }
    
    private func validateCompany() -> Bool {
        
        if let item = self.archiveItem {
            if let company = item.company {
                return true
            }
        }
        
        return false
    }
    
    
    private func validatePerson() -> Bool {
        
        if let item = self.archiveItem {
            if let company = item.company {
                if let employee = item.employee {
                    if employee.company.companyId == company.companyId {
                        return true
                    }
                }
            }
            
        }
        return false
    }
}
