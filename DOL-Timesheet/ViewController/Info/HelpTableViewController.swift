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

    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactUsView: UIView!
    @IBOutlet weak var glossaryView: UIView!
    @IBOutlet weak var helpItemTable: UITableView!
    //    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var contactUsImageView: UIImageView!
    
    @IBOutlet weak var glossaryLabel: UILabel!
    @IBOutlet weak var contactUsLabel: UILabel!
    
    var helpItems: [HelpItem] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
    }
    
    func setupView() {
        
        let backButton = UIBarButtonItem()
        backButton.title = "back".localized
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.title = "help".localized

        
        let originalImage = UIImage(named: "contact us")
        contactUsImageView.image = originalImage
        
        glossaryLabel.text = "glossary".localized
        contactUsLabel.text = "contact_us".localized

        contactUsImageView.tintColor = UIColor(named: "appPrimaryColor")
        contactUsImageView.image = contactUsImageView.image?.withRenderingMode(.alwaysTemplate)
        
        helpItemTable.reloadData()
        helpItemTable.layer.cornerRadius = 10
        glossaryView.layer.cornerRadius = 10
        contactUsView.layer.cornerRadius = 10
        tableHeightConstraint.constant = CGFloat((45 * helpItems.count))
        setupAccessibility()
    }
    
    func setupAccessibility() {
        
        
//        displayLogo.isAccessibilityElement = true
//        displayLogo.accessibilityLabel = "whd_logo".localized
    }
    
    @objc func cancel(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
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
        
        cell.textLabel?.scaleFont(forDataType: .infoSection)
        cell.textLabel?.text = helpItems[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension HelpTableViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "helpDetail", sender: nil)
    }
}
