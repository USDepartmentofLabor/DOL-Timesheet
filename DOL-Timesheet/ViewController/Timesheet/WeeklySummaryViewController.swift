//
//  WeeklySummaryViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 1/19/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit
import MessageUI

class WeeklySummaryViewController: UIViewController, TimeViewDelegate, TimePickerProtocol {

    @IBOutlet weak var weeklyTableView: UITableView!

    lazy var viewModel: TimesheetViewModel = TimesheetViewModel()
    var summaryTableData: [[PayPeriodSummary]] = []
    var payPeriodSummaryData: [PayPeriodSummary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
       // self.setupLabelTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayInfo()
    }
    
    func setupView() {
        
        title = "timesheet".localized
                
        
        weeklyTableView.register(UINib(nibName: TimeEntryViewCell.nibName, bundle: nil), forCellReuseIdentifier: TimeEntryViewCell.reuseIdentifier)
        weeklyTableView.rowHeight = UITableView.automaticDimension
        weeklyTableView.estimatedRowHeight = 40
        
//        timeTableView.backgroundColor = UIColor.systemGray5
//        2C2C2E dark
//        E5E5EA light
    }
    
    func displayInfo() {
        viewModel.updatePeriod()
        displayPeriodInfo()
    }
    
    func displayPeriodInfo() {
        payPeriodSummaryData = []
        payPeriodSummaryData.append(PayPeriodSummary(name: "Total Hours Worked", value1: "xx hrs", value2: "x min"))
        viewModel.currentEmploymentModel?.hourlyRates?.forEach {rate in
            payPeriodSummaryData.append(PayPeriodSummary(name: rate.title, value1: "xx hrs", value2: "x min"))
        }
        payPeriodSummaryData.append(PayPeriodSummary(name: "Break Hours", value1: "xx hrs", value2: "x min"))
        payPeriodSummaryData.append(PayPeriodSummary(name: "Overtime", value1: "xx hrs", value2: "x min"))
        payPeriodSummaryData.append(PayPeriodSummary(name: "Weekly Summary", value1: "", value2: ""))
        weeklyTableView.reloadData()
        
//        self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        
       // displayTotals()
    }

    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        return
    }
    
    @IBAction func payPeriodPressed(_ sender: Any) {
        
    }
    
    func donePressed() {
        
    }
}

////MARK : TableView DataSource Delegate
extension WeeklySummaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return viewModel.numberOfWorkWeeks
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
//        headerView.backgroundColor = UIColor.systemGray5

        let titleLabel = UILabel()
        let sectionTitle = titleForWorkWeek(week: section)
        
        titleLabel.text = sectionTitle // Customize the header text
        titleLabel.textColor = UIColor(named: "darkTextColor") // Customize the text color
        titleLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 30) // Adjust the frame as needed
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)

        headerView.addSubview(titleLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + (viewModel.currentEmploymentModel?.hourlyRates?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let hourlyCell = tableView.dequeueReusableCell(withIdentifier: TimeEntryViewCell.reuseIdentifier) as! TimeEntryViewCell
        let numDays = viewModel.currentPeriod?.numberOfDays() ?? 0
        let section = indexPath.section
        let row = indexPath.row
        
        var title = ""
        var totalTime = ""
        
        if row == 0 {
            // TOTAL HOURS WORKED
            // Section Identifies Work Week
            // Get total hours for work week and set hrs / mins
            title = "TOTAL HOURS WORKED"
            totalTime = viewModel.hoursWorked(workWeek: indexPath.section)
        } else if row < (1 + (viewModel.currentEmploymentModel?.hourlyRates?.count ?? 1)) {
            // Multiple RATES
            // Section Identifies Work Week
            // Row - 1 Identifies rate to get total for and set hrs / mins
        } else if row == (1 + (viewModel.currentEmploymentModel?.hourlyRates?.count ?? 1)) {
            // BREAK TIME
            // Section Identifies Work Week
            // Get break Time for work week and set hrs / mins
            title = "Break Time"
            totalTime = viewModel.breakTimeHours(workWeek: indexPath.section)

        } else {
            // OVERTIME
            // Section Identifies Work Week
            // Get overtime for work week and set hrs / mins
            title = "Overtime"

            totalTime = viewModel.overTimeHours(workWeek: indexPath.section)
        }
        
        hourlyCell.rateName.text = title
        hourlyCell.timeFrame.text = ""
        hourlyCell.totalTime.text = totalTime
        
        
        hourlyCell.layer.cornerRadius = 10
        hourlyCell.layer.masksToBounds = true
        
        return hourlyCell
    }
}

//MARK : TableView DataSource Delegate
extension WeeklySummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        return
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = viewModel.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "Work Week\(week+1): \(workWeekViewModel.title)"
    }
    
}

//// MARK: Toolbar Actions
extension WeeklySummaryViewController {
    
    func export(_ sender: Any) {
        guard let csvPath = viewModel.csv() else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [csvPath as Any], applicationActivities: [])
        vc.excludedActivityTypes = [
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.openInIBooks]
        
        if let popOver = vc.popoverPresentationController {
            if let senderBtn = sender as? UIBarButtonItem {
                popOver.barButtonItem = senderBtn
            }
            else {
                popOver.sourceView = self.view
            }
        }
        
        vc.completionWithItemsHandler = { (type,completed,items,error) in
            // Delete the File
            try? FileManager.default.removeItem(at: csvPath)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func emailTimesheet() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["email@email.com"])
        mailComposerVC.setSubject("Timesheet Report")
        mailComposerVC.setMessageBody("Body", isHTML: false)
        present(mailComposerVC, animated: true, completion: nil)
    }
    
    func addNewUser() {
        performSegue(withIdentifier: "addEmploymentInfo", sender: self)
    }
    
    func setCurrentUser(user: User) {
        viewModel.setCurrentEmploymentModel(for: user)
    }
         
}

extension WeeklySummaryViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}


extension WeeklySummaryViewController: TimeViewControllerDelegate {
    func didUpdateUser() {
        if let user = viewModel.userProfileModel.employmentUsers.first {
            self.setCurrentUser(user: user)
        }
        displayInfo()
    }
    
    func didUpdateEmploymentInfo() {
     //   displayEmploymentInfo()
    }
    
    func didUpdateLanguageChoice() {
        displayInfo()
     //   displayEmploymentInfo()
    }
}
