//
//  SettingsViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 10/13/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var settingsTable: UITableView!
    let cellReuseIdentifier = "cell"
    let settingsOptions: [String] = ["My Profile", "Employers & Employees"]
    
    class var nib: String {return "SettingsTableViewController"}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func settingsTable(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsOptions.count
    }
    
    func settingsTable(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        cell.textLabel?.text = self.settingsOptions[indexPath.row]
        
        return cell
    }
    
    func settingsTable(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let indexPath = tableView.indexPathForSelectedRow
//        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
        var viewController: UIViewController?
        
        if indexPath.row == 0 {
            viewController = SettingsProfileViewController(nibName: "My Profile", bundle: nil)
        } else if indexPath.row == 1 {
            viewController = SettingsEmploymentTableViewController(nibName: "Employers", bundle: nil)
        }

        self.navigationController?.pushViewController(viewController!, animated: true)
    }

}
