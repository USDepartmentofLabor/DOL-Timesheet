//
//  HelpTableViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

struct HelpItem {
    var title: String
    var body: String
}

class HelpTableViewController: UIViewController {

    @IBOutlet weak var helpItemTable: UITableView!
    //    @IBOutlet weak var displayLogo: UIImageView!
    
    var helpItems: [HelpItem] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        helpItemTable.reloadData()
        setupAccessibility()
    }
    
    func setupAccessibility() {
//        displayLogo.isAccessibilityElement = true
//        displayLogo.accessibilityLabel = "whd_logo".localized
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "helpDetail",
//            let helpVC = segue.destination as? HelpTableViewController {
//            helpVC.helpItems = [
//                HelpItem(
//                    title: "info_break_time_title".localized,
//                    body: "info_break_time".localized),
//                HelpItem(title: "overnight_hours".localized, body: "info_end_time")]
//        }
    }
}

extension HelpTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "helpItem")
        
        cell.textLabel?.scaleFont(forDataType: .aboutText)
        cell.textLabel?.text = helpItems[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}

extension HelpTableViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "helpDetail", sender: nil)
    }
}
