//
//  ArchiveEmailVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 21..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//


enum ArchiveInfoCategory {
    case Company, Person, Order
}

struct ArchiveInfo {
    
    var category: ArchiveInfoCategory
    var label = ""
    var value = ""
    
    init(category: ArchiveInfoCategory, label: String) {
        self.category = category
        self.label = label
    }
}


class ArchiveEmailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var items = [ArchiveInfo]();
    
    var archiveItem: Archive?
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchIcon = FAKIonIcons.iosSearchIconWithSize(30)

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [ArchiveInfo(category: ArchiveInfoCategory.Company, label: "Company"),
            ArchiveInfo(category: ArchiveInfoCategory.Person, label: "Person"),
            ArchiveInfo(category: ArchiveInfoCategory.Order, label: "Order")]
        
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Segues
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }
    
    // MARK - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        
        cell.textLabel?.text = items[indexPath.row].label
//        cell.detailTextLabel?.text = items[indexPath.row].value
        cell.detailTextLabel?.text = "Subtitle #\(indexPath.row)"
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.accessoryView = UIImageView(image: searchIcon.imageWithSize(CGSize(width: 30, height: 30)))
        return cell
    }
    
    @IBAction func unwindToArchiveEmail(segue: UIStoryboardSegue?) {
    }
    
    
}
