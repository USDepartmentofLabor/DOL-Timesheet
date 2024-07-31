//
//  EarningDetailViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 5/6/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

class EarningDetailViewController: UIViewController {
    @IBOutlet weak var earningTableView: UITableView!

//    @IBOutlet weak var helpLabel: UILabel!
//    @IBOutlet weak var helpView: UIView!
    
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
        
        title = "earning_details".localized
        
//        helpLabel.text = "help".localized
//        helpView.layer.cornerRadius = 10
                
        
        earningTableView.register(UINib(nibName: EarningDetailTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EarningDetailTableViewCell.reuseIdentifier)
        earningTableView.register(UINib(nibName: HelpTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: HelpTableViewCell.reuseIdentifier)

        earningTableView.rowHeight = UITableView.automaticDimension
     //   earningTableView.estimatedRowHeight = 90
        
    }
    
    func displayInfo() {
     //   timesheetViewModel.updatePeriod()
        displayPeriodInfo()
    }
    
    func displayPeriodInfo() {
        earningTableView.reloadData()
        
//        self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        
       // displayTotals()
    }

    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        return
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "earningDetailHelpSegue",
            let helpVC = segue.destination as? HelpTableViewController {
            helpVC.helpItems = [
                HelpItem(
                    title: "overtime_pay".localized,
                    body: "info_glossary_overtime".localized),
                HelpItem(
                    title: "regular_rate_of_pay".localized,
                    body: "info_regular_rate_pay".localized)]
        }
    }
}


extension EarningDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return timesheetViewModel.numberOfWorkWeeks + 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()

        let titleLabel = UILabel()
        
        var sectionTitle = ""
        if (section == 0) {
            sectionTitle = "Pay Period Total"
        } else if (section > 0 && section < timesheetViewModel.numberOfWorkWeeks + 1) {
            sectionTitle = titleForWorkWeek(week: section-1)!
        }
        
        titleLabel.text = sectionTitle // Customize the header text
        titleLabel.textColor = UIColor(named: "darkTextColor") // Customize the text color
        titleLabel.frame = CGRect(x: 8, y: 0, width: tableView.frame.width - 30, height: 30) // Adjust the frame as needed
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)

        headerView.addSubview(titleLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return 3
            case timesheetViewModel.numberOfWorkWeeks + 1: return 1
            default: return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let earningCell = tableView.dequeueReusableCell(withIdentifier: EarningDetailTableViewCell.reuseIdentifier) as! EarningDetailTableViewCell
        let helpCell = tableView.dequeueReusableCell(withIdentifier: HelpTableViewCell.reuseIdentifier) as! HelpTableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        var belowMinimumWage: Bool
        
        if timesheetViewModel.currentEmploymentModel?.paymentType == .salary {
            belowMinimumWage = timesheetViewModel.isBelowSalaryWeeklyWage()
        } else {
            belowMinimumWage = timesheetViewModel.isBelowMinimumWage()
        }
        
        earningCell.minimumWarningTitle.text = "minimum_wage_warning".localized

        
        if section == 0 {
            switch row {
            case 0:
                earningCell.rateTitle.text = "Earnings"
                earningCell.rateValue.text = timesheetViewModel.totalEarningsStr
                earningCell.firstItem = true
                earningCell.lastItem = false
                
                earningCell.configure(isTotalEarnings: true, hasWarning: true, warningEnabled: belowMinimumWage)
            case 1:
                earningCell.rateTitle.text = "Straight Time"
                earningCell.rateValue.text = timesheetViewModel.currentPeriod?.straightTimeAmountStr ?? "$0.00"
                earningCell.firstItem = false
                earningCell.lastItem = false
                
                earningCell.configure(isTotalEarnings: true)
            case 2:
                earningCell.rateTitle.text = "Overtime"
                earningCell.rateValue.text = timesheetViewModel.periodOvertimeAmountStr
                earningCell.firstItem = false
                earningCell.lastItem = true
                
                earningCell.configure(isTotalEarnings: true)
            default:
                break
            }
        } else if (section == timesheetViewModel.numberOfWorkWeeks + 1) {
            helpCell.setup()
            return helpCell
        } else {
            let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: indexPath.section - 1)
            
            switch row {
            case 0:
                earningCell.rateTitle.text = "Earnings"
                earningCell.rateValue.text = workWeekViewModel?.totalEarningsStr ?? "0.00"
                earningCell.firstItem = true
                earningCell.lastItem = false
                
                earningCell.configure(isTotalEarnings: true)
            case 1:
                earningCell.rateTitle.text = "Straight Time"
                earningCell.rateHintTitle.text = "(Hrs x Rate)"
                earningCell.rateHint.text = workWeekViewModel?.straightTimeCalculationsStr ?? "9 hrs x $1.00 = $9.00"
                earningCell.rateValue.text = workWeekViewModel?.straightTimeAmountStr ?? "0.00"
                earningCell.firstItem = false
                earningCell.lastItem = false
                
                earningCell.configure(isTotalEarnings: false)
            case 2:
                earningCell.rateTitle.text = "Overtime"
                earningCell.rateHintTitle.text = "(Rate x 0.5 x Hrs)"
                earningCell.rateHint.text = workWeekViewModel?.overtimeCalculationStr ?? "$3.00 / hr x 0.5 x 0 Hrs"
                earningCell.rateValue.text = workWeekViewModel?.overtimeAmountStr
                earningCell.firstItem = false
                earningCell.lastItem = false
                
                earningCell.configure(isTotalEarnings: false)
            case 3:
                earningCell.rateTitle.text = "Regular Rate of Pay"
                earningCell.rateHintTitle.text = "(Straight Time Earnings / Hrs)"
                earningCell.rateHint.text = workWeekViewModel?.regularRateCalculationStr ?? "$54.00 / 18 Hrs = $3.00 / Hr"
                earningCell.rateValue.text = workWeekViewModel?.regularRateStr ?? "$7.25/hr"
                earningCell.firstItem = false
                earningCell.lastItem = true
                
                earningCell.configure(isTotalEarnings: false, hasWarning: true, warningEnabled: belowMinimumWage)
            default:
                break
            }
        }
        
        return earningCell
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
}
//MARK : TableView DataSource Delegate
extension EarningDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after selection

        if indexPath.section == timesheetViewModel.numberOfWorkWeeks + 1 {
            performSegue(withIdentifier: "earningDetailHelpSegue", sender: self)
        }
        
        return
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "\("work_week".localized) \(week+1): \(workWeekViewModel.title)"
    }
    
}
