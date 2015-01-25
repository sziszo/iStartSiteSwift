//
//  ReportVC.swift
//  iStartSiteSwift
//
//  Created by Szilard Antal on 2015. 01. 22..
//  Copyright (c) 2015. Szilard Antal. All rights reserved.
//


struct ReportItem {
    var id = 0
    var name = ""
}


class ReportVC: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var historyItems = [ReportItem]()
    
    var reportItems = [ReportItem]()
    var filteredReportItems = [ReportItem]()
    
    var selectedReportItem: ReportItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyItems = [ReportItem(id: 1, name: "Elso"), ReportItem(id: 2, name: "Masodik"), ReportItem(id: 3, name: "Harmadik"), ReportItem(id: 4, name: "Negyedik")]
        
        reportItems = historyItems
    }
    
    // MARK - TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredReportItems.count
        } else {
            return self.historyItems.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ReportCell") as UITableViewCell
        
        var reportItem : ReportItem
        if tableView == self.searchDisplayController!.searchResultsTableView {
            reportItem = filteredReportItems[indexPath.row]
        } else {
            reportItem = historyItems[indexPath.row]
        }
        
        // Configure the cell
        cell.textLabel!.text = reportItem.name
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var reportItem : ReportItem
        if tableView == self.searchDisplayController!.searchResultsTableView {
            reportItem = filteredReportItems[indexPath.row]
        } else {
            reportItem = historyItems[indexPath.row]
        }
        
        self.selectedReportItem = reportItem
        
        self.performSegueWithIdentifier("returnToArchive", sender: tableView)
    }
    
    // MARK - Search
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    
    // MARK - Filter
    
    func filterContentForSearchText(searchText: String) {
        self.filteredReportItems = self.reportItems.filter({( candy : ReportItem) -> Bool in
            var stringMatch = candy.name.rangeOfString(searchText)
            return stringMatch != nil
        })
    }
    
    
}
