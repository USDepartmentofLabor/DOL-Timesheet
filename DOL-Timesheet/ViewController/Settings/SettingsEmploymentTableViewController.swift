//
//  SettingsEmploymentTableViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 10/15/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class SettingsEmploymentTableViewController: UITableViewController {
    @IBOutlet var employmentTable: UITableView!
    let cellReuseIdentifier = "cell"
    let settingsOptions: [String] = ["John Doe"]
    
    lazy var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func settingsTable(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileViewModel.employmentUsers.count
    }
    
    func settingsTable(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        cell.textLabel?.text = profileViewModel.employmentUsers[indexPath.row].name
        
        return cell
    }
    
    func settingsTable(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
    }
}
