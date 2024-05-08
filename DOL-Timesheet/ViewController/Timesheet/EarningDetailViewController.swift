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
        earningTableView.rowHeight = UITableView.automaticDimension
        earningTableView.estimatedRowHeight = 70
        
//        timeTableView.backgroundColor = UIColor.systemGray5
//        2C2C2E dark
//        E5E5EA light
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
                    title: "info_break_time_title".localized,
                    body: "info_break_time".localized),
                HelpItem(title: "overnight_hours".localized, body: "info_end_time".localized)]
        }
    }
}


extension EarningDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        print("Earning setion: \(timesheetViewModel.numberOfWorkWeeks + 1)")
        return timesheetViewModel.numberOfWorkWeeks + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()

        let titleLabel = UILabel()
        
        var sectionTitle = "Pay Period Total"
        if (section > 0) {
            sectionTitle = titleForWorkWeek(week: section-1)!
        }
        
        titleLabel.text = sectionTitle // Customize the header text
        titleLabel.textColor = UIColor(named: "darkTextColor") // Customize the text color
        titleLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 30) // Adjust the frame as needed
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)

        headerView.addSubview(titleLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let paymentType = timesheetViewModel.currentEmploymentModel?.paymentType
        
        let earningCell = tableView.dequeueReusableCell(withIdentifier: EarningDetailTableViewCell.reuseIdentifier) as! EarningDetailTableViewCell
        let numDays = timesheetViewModel.currentPeriod?.numberOfDays() ?? 0
        let section = indexPath.section
        let row = indexPath.row
        
        var title = ""
        var totalTime = ""
        
        var belowMinimumWage = timesheetViewModel.isBelowMinimumWage()
        
        if section == 0 {
            switch row {
            case 0:
                earningCell.rateTitle.text = "Earnings"
                earningCell.rateValue.text = timesheetViewModel.totalEarningsStr
                
                earningCell.configure(isTotalEarnings: true, isBelowMinimumWage: belowMinimumWage)
            case 1:
                earningCell.rateTitle.text = "Straight Time"
                earningCell.rateValue.text = timesheetViewModel.currentPeriod?.straightTimeAmountStr ?? "$0.00"
                
                earningCell.configure(isTotalEarnings: true, isBelowMinimumWage: belowMinimumWage)
            case 2:
                earningCell.rateTitle.text = "Overtime"
                earningCell.rateValue.text = timesheetViewModel.periodOvertimeAmountStr
               
                earningCell.configure(isTotalEarnings: true, isBelowMinimumWage: belowMinimumWage)
            default:
                break
            }
        } else {
            switch row {
            case 0:
                earningCell.rateTitle.text = "Earnings"
                earningCell.rateValue.text = timesheetViewModel.totalEarningsStr
                
                earningCell.configure(isTotalEarnings: true, isBelowMinimumWage: belowMinimumWage)
            case 1:
                earningCell.rateTitle.text = "Straight Time"
                earningCell.rateHintTitle.text = "(Hrs x Rate)"
                earningCell.rateHint.text = "9 hrs x $1.00 = $9.00"
                earningCell.rateValue.text = timesheetViewModel.currentPeriod?.straightTimeAmountStr ?? "$0.00"
                
                earningCell.configure(isTotalEarnings: false, isBelowMinimumWage: belowMinimumWage)
            case 2:
                earningCell.rateTitle.text = "Overtime"
                earningCell.rateHintTitle.text = "(Rate x 0.5 x Hrs)"
                earningCell.rateHint.text = "$3.00 / hr x 0.5 x 0 Hrs"
                earningCell.rateValue.text = timesheetViewModel.periodOvertimeAmountStr
                
                earningCell.configure(isTotalEarnings: false, isBelowMinimumWage: belowMinimumWage)
            case 3:
                earningCell.rateTitle.text = "Regular Rate of Pay"
                earningCell.rateHintTitle.text = "(Straight Time Earnings / Hrs)"
                earningCell.rateHint.text = "$54.00 / 18 Hrs = $3.00 / Hr"
                earningCell.rateValue.text = "$7.25/hr"
               
                earningCell.configure(isTotalEarnings: false, isBelowMinimumWage: belowMinimumWage)
            default:
                break
            }
        }
        
        return earningCell
    }
    
    func calcRateHoursWorked(weekIndex: Int, rate: HourlyRate)-> String {
        
        guard let workWeek = timesheetViewModel.currentPeriod?.workWeeks[weekIndex] else { return "xx hrs xx min" }
        let workWeekDaysInPeriod = workWeek.days
        
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
        
        return
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "\("work_week".localized) \(week+1): \(workWeekViewModel.title)"
    }
    
}
