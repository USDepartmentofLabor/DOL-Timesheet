//
//  WeeklySummaryViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 1/19/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit
import MessageUI

class WeeklySummaryViewController: UIViewController {

    @IBOutlet weak var weeklyTableView: UITableView!

    var timesheetViewModel = TimesheetViewModel.shared()
    
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
        
        title = "weekly_summary".localized
                
        
        weeklyTableView.register(UINib(nibName: EarningDetailsViewCell.nibName, bundle: nil), forCellReuseIdentifier: EarningDetailsViewCell.reuseIdentifier)
        weeklyTableView.rowHeight = UITableView.automaticDimension
        weeklyTableView.estimatedRowHeight = 40
        
//        timeTableView.backgroundColor = UIColor.systemGray5
//        2C2C2E dark
//        E5E5EA light
    }
    
    func displayInfo() {
     //   timesheetViewModel.updatePeriod()
        displayPeriodInfo()
    }
    
    func displayPeriodInfo() {
        weeklyTableView.reloadData()
        
//        self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        
       // displayTotals()
    }
    
    func makeBold(input: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: input)
        
        // Apply bold style to digits, dollar sign, and period
        for i in 0..<input.count {
            let index = input.index(input.startIndex, offsetBy: i)
            let c = input[index]
            
            if c.isNumber || c == "$" || c == "." {
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: NSRange(location: i, length: 1))
            }
        }
        
        return attributedString
    }
}

////MARK : TableView DataSource Delegate
extension WeeklySummaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return timesheetViewModel.numberOfWorkWeeks
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
        if timesheetViewModel.currentEmploymentModel?.paymentType == .hourly {
            return 3 + (timesheetViewModel.currentEmploymentModel?.hourlyRates?.count ?? 0)
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let paymentType = timesheetViewModel.currentEmploymentModel?.paymentType
        
        let hourlyCell = tableView.dequeueReusableCell(withIdentifier: EarningDetailsViewCell.reuseIdentifier) as! EarningDetailsViewCell
        let numDays = timesheetViewModel.currentPeriod?.numberOfDays() ?? 0
        let section = indexPath.section
        let row = indexPath.row
        
        var numberOfRates = 1
        if timesheetViewModel.currentEmploymentModel?.paymentType == .hourly {
            numberOfRates = timesheetViewModel.currentEmploymentModel?.hourlyRates?.count ?? 1
        }
        
        var title = ""
        var totalTime = ""
                
        if row == 0 {
            // TOTAL HOURS WORKED
            // Section Identifies Work Week
            // Get total hours for work week and set hrs / mins
            title = "total_hours_worked".localized.uppercased()
            totalTime = timesheetViewModel.hoursWorked(workWeek: indexPath.section)
            hourlyCell.firstItem = true
            hourlyCell.lastItem = false
        } else if (row < numberOfRates + 1) {
            // Multiple RATES
            // Section Identifies Work Week
            // Row - 1 Identifies rate to get total for and set hrs / mins
            
            title = "payment_type_salary".localized
            totalTime = "xx hrs xx mins"
            
            if timesheetViewModel.currentEmploymentModel?.paymentType == .salary {
                if let salary = timesheetViewModel.currentEmploymentModel?.salary.salaryType.title.localized {
                    title = salary
                    totalTime = calcSalaryHoursWorked(weekIndex: section)
                }
            } else {
                title = "Rate Title"
                totalTime = "xx hrs xx mins"
                if let rate = timesheetViewModel.currentEmploymentModel?.hourlyRates?[row-1] {
                    title = rate.title
                    totalTime = calcRateHoursWorked(weekIndex: section, rate: rate)
                }
            }
            hourlyCell.firstItem = false
            hourlyCell.lastItem = false
            
        } else if row == numberOfRates + 1 {
            // BREAK TIME
            // Section Identifies Work Week
            // Get break Time for work week and set hrs / mins
            title = "break_time".localized
            totalTime = timesheetViewModel.breakTimeHours(workWeek: indexPath.section)
            hourlyCell.firstItem = false
            hourlyCell.lastItem = false

        } else {
            // OVERTIME
            // Section Identifies Work Week
            // Get overtime for work week and set hrs / mins
            title = "overtime".localized

            totalTime = timesheetViewModel.overTimeHours(workWeek: indexPath.section)
            hourlyCell.firstItem = false
            hourlyCell.lastItem = true
        }
        
        hourlyCell.rateName.text = title
        
        if row == 0 {
            let attributedString = NSMutableAttributedString(string: title)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: range)
            hourlyCell.rateName.attributedText = attributedString
        }
        
        hourlyCell.totalTime.attributedText = makeBold(input: totalTime)
        hourlyCell.totalTime.textColor = UIColor(named: "purpleColor")
        
        hourlyCell.addborder()
        
        return hourlyCell
    }
    
    func calcRateHoursWorked(weekIndex: Int, rate: HourlyRate)-> String {
        guard let workWeek = timesheetViewModel.currentPeriod?.workWeeks[weekIndex] else { return "xx hrs xx min" }
        
        var totalRateHours = 0
        workWeek.days.forEach {
            totalRateHours += timesheetViewModel.rateTotalHours(forRate: rate, forDate: $0)
        }
        let hrsMinStr: String = Date.secondsToHoursMinutes(seconds: Double(totalRateHours))
        return hrsMinStr
    }
    
    func calcSalaryHoursWorked(weekIndex: Int)-> String {
        guard let workWeek = timesheetViewModel.currentPeriod?.workWeeks[weekIndex] else { return "xx hrs xx min" }
        
        var totalRateHours = 0.0
        workWeek.days.forEach {
            totalRateHours += timesheetViewModel.totalHoursTime(forDate: $0)
        }
        let hrsMinStr: String = Date.secondsToHoursMinutes(seconds: Double(totalRateHours))
        return hrsMinStr
    }
}

//MARK : TableView DataSource Delegate
extension WeeklySummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        return
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "\("work_week".localized) \(week+1): \(workWeekViewModel.title)"
    }
    
}

//// MARK: Toolbar Actions
extension WeeklySummaryViewController {
    
    func export(_ sender: Any) {
        guard let csvPath = timesheetViewModel.csv() else {
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
        timesheetViewModel.setCurrentEmploymentModel(for: user)
    }
         
}

extension WeeklySummaryViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}


extension WeeklySummaryViewController: TimeViewControllerDelegate {
    func didUpdateUser() {
        if let user = timesheetViewModel.userProfileModel.employmentUsers.first {
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
