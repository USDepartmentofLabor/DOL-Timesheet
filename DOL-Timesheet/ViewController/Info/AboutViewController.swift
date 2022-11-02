//
//  AboutViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    
    let items = ["introduction_text1".localized,
       "introduction_text2".localized,
       "\("version_number".localized)  \(Bundle.main.versionNumber).\(Bundle.main.buildNumber)"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.isAccessibilityElement = true
        displayLogo.accessibilityLabel = "whd_logo".localized
    }
}

extension AboutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "aboutCell")
        
        if indexPath.row == 0 {
            cell.textLabel?.scaleFont(forDataType: .introductionBoldText)
        }
        else {
            cell.textLabel?.scaleFont(forDataType: .aboutText)
        }
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}
