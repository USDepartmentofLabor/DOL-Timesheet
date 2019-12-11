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
    
    let items = [NSLocalizedString("introduction_text1", comment: "Introduction text1"),
       NSLocalizedString("introduction_text2", comment: "Introduction text2"),
       "Version Number: \(Bundle.main.versionNumber).\(Bundle.main.buildNumber)"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.isAccessibilityElement = true
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
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
