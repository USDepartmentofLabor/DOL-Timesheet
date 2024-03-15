//
//  SetupWorkWeekViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SetupWorkWeekViewController: SetupBaseEmploymentViewController {
    
    @IBOutlet weak var titleLabelInfo: LabelInfoView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    override func setupView() {
        super.setupView()
        
        title = "work_week".localized
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        if employmentModel?.isProfileEmployer ?? false {
            titleLabelInfo.title = "work_week_employer".localized
            titleLabelInfo.infoType = .employer_workweek
        }
        else {
            titleLabelInfo.title = "work_week_employee".localized
            titleLabelInfo.infoType = .employee_workweek
        }
        titleLabelInfo.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}

extension SetupWorkWeekViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Add + 1 for Do not Know
        return Weekday.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkWeekTableViewCell.reuseIdentifier) as! WorkWeekTableViewCell
        
        if indexPath.row < Weekday.allCases.count {
            cell.weekday = Weekday.allCases[indexPath.row]
        }
        else {
            cell.weekday = nil
        }
        cell.delegate = self
        return cell
    }
}

extension SetupWorkWeekViewController: WorkWeekCellDelegate {
    func select(weekday: Weekday?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "back".localized
        navigationItem.backBarButtonItem = backItem
        
        employmentModel?.workWeekStartDay = weekday ?? .sunday
        performSegue(withIdentifier: "setupPaymentInfo", sender: self)
    }
}
