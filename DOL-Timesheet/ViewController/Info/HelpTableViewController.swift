//
//  HelpTableViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

public struct HelpItem {
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
        
        navigationItem.leftBarButtonItem?.tintColor = .black
//        let cancelBtn = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: nil)
//        navigationItem.leftBarButtonItem = cancelBtn
//
//        let saveBtn = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: nil)
//        navigationItem.rightBarButtonItem = saveBtn
        
        
//        displayLogo.isAccessibilityElement = true
//        displayLogo.accessibilityLabel = "whd_logo".localized
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "helpDetail",
            let helpDetailVC = segue.destination as? HelpDetailViewController {
            helpDetailVC.helpItem = helpItems[selectedIndex]
        }
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
