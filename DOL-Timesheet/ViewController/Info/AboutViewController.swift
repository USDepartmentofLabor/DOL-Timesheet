//
//  AboutViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    let items = ["The Department of Labor is providing this app as a public service. This is a service that is continually under development. The user should be aware that, while we try to keep the information timely and accurate, there will often be a delay between official publication of the materials and their appearance in or modification of this system. Further, the conclusions reached by this system rely on the accuracy of the data provided by the user. Therefore, we make no express or implied guarantees. The Federal Register and the Code of Federal Regulations remain the official sources for regulatory information published by the Department of Labor. We will make every effort to correct errors brought to our attention.",
       "Please note that information input via this app is never shared with the Department of Labor for any purposes.",
       "Version Number: \(Bundle.main.versionNumber).\(Bundle.main.buildNumber)"]
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
    
        cell.textLabel?.scaleFont(forDataType: .aboutText)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
}
