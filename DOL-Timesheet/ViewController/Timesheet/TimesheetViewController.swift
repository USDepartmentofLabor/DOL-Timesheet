//
//  TimesheetViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import MessageUI


protocol TimeViewControllerDelegate: class {
    func didUpdateUser()
    func didUpdateEmploymentInfo()
    func didUpdateLanguageChoice()
}

protocol EnterTimeViewControllerDelegate: class {
    func didEnterTime(enterTimeModel: EnterTimeViewModel?)
    func didCancelEnterTime()
}

protocol TimeCardViewControllerDelegate: class {
    func didEnterTime(enterTimeModel: EnterTimeViewModel?)
}


class TimesheetViewController: UIViewController, TimeViewDelegate, TimePickerProtocol {

    @IBOutlet weak var periodView: UIView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var prevPeriodBtn: UIButton!
    @IBOutlet weak var nextPeriodBtn: UIButton!
    
    @IBOutlet weak var enterTimeTitleLabel: UILabel!
    @IBOutlet weak var headingDayLabel: UILabel!
    @IBOutlet weak var headingTotalHoursLabel: UILabel!
    @IBOutlet weak var headingTotalBreakLabel: UILabel!

    @IBOutlet weak var breakInfoButton: InfoButton!
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var timeTableviewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalHoursWorkedLabel: UILabel!
    @IBOutlet weak var totalBreakLabel: UILabel!
 
    // SummaryView
    @IBOutlet weak var summaryContentView: UIView!
    
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var summaryTableView: UITableView!
    @IBOutlet weak var summaryTableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var earningsTitleLabel: UILabel!
    @IBOutlet weak var totalEarningsBtn: UIButton!
    @IBOutlet weak var totalEarningsAmountLabel: UILabel!
    @IBOutlet weak var totalEarningsWarningLabel: UILabel!
    
    @IBOutlet weak var periodEarningsStackView: UIStackView!
    @IBOutlet weak var periodStraightTimeEarningsStackView: UIStackView!
    @IBOutlet weak var periodOvertimeEarningsStackView: UIStackView!
    @IBOutlet weak var periodStraightTimeTitle: UILabel!
    @IBOutlet weak var periodStraightTimeAmount: UILabel!
    @IBOutlet weak var periodOvertimeTitle: UILabel!
    @IBOutlet weak var periodOvertimeInfoBtn: InfoButton!
    
    @IBOutlet weak var periodOvertimeAmount: UILabel!
    @IBOutlet weak var earningsTableView: UITableView!
    @IBOutlet weak var earningsTableViewHeightConstraint: NSLayoutConstraint!
    
    var timePickerVC = TimePickerViewController.instantiateFromStoryboard()
    
    var earningsCollapsed: Bool = true {
        didSet {
            let img: UIImage
            let accessibilityHint: String
            if earningsCollapsed {
                img = #imageLiteral(resourceName: "collape")
                accessibilityHint = "total_Earnings_expand_hint".localized
            }
            else {
                img = #imageLiteral(resourceName: "expand")
                accessibilityHint = "total_Earnings_collapse_hint".localized
            }
            totalEarningsBtn.setImage(img, for: .normal)
            totalEarningsBtn.accessibilityHint = accessibilityHint
            refreshEarnings()
        }
    }
    
    // Earnings View
    @IBOutlet weak var earningsContentView: UIView!
    
    var timesheetViewModel = TimesheetViewModel.shared()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        self.setupLabelTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timeTableviewHeightConstraint.constant = timeTableView.contentSize.height
        earningsTableViewHeightConstraint.constant = earningsTableView.contentSize.height
        summaryTableViewHeightConstraint.constant = summaryTableView.contentSize.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        guard let viewModel = viewModel, viewModel.userProfileExists else {
//            performSegue(withIdentifier: "setupProfile", sender: nil)
//            return
//        }
//
//        timeTableviewHeightConstraint.constant = timeTableView.contentSize.height
    }
    
    func setupView() {
        timeView.addBorder()
        periodView.addBorder()
        
        timeTableView.rowHeight = UITableView.automaticDimension
        timeTableView.estimatedRowHeight = 50
        
        summaryTableView.rowHeight = UITableView.automaticDimension
        summaryTableView.estimatedRowHeight = 30
        summaryTableView.register(UINib(nibName: SummaryTableViewHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SummaryTableViewHeaderView.reuseIdentifier)
        summaryTableView.sectionHeaderHeight = UITableView.automaticDimension;
        summaryTableView.estimatedSectionHeaderHeight = 44

        earningsTableView.register(UINib(nibName: EarningsTableViewHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: EarningsTableViewHeaderView.reuseIdentifier)
        earningsTableView.sectionHeaderHeight = UITableView.automaticDimension;
        earningsTableView.estimatedSectionHeaderHeight = 44

        earningsTableView.register(UINib(nibName: EarningsTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: EarningsTableViewCell.reuseIdentifier)
        earningsTableView.rowHeight = UITableView.automaticDimension
        earningsTableView.estimatedRowHeight = 200

        periodLabel.scaleFont(forDataType: .timesheetPeriod)
        headingDayLabel.scaleFont(forDataType: .columnHeader)
        headingTotalHoursLabel.scaleFont(forDataType: .columnHeader)
        headingTotalBreakLabel.scaleFont(forDataType: .columnHeader)
        enterTimeTitleLabel.scaleFont(forDataType: .timesheetSectionTitle)
        summaryTitleLabel.scaleFont(forDataType: .timesheetSectionTitle)
        earningsTitleLabel.scaleFont(forDataType: .timesheetSectionTitle)
        totalTitleLabel.scaleFont(forDataType: .timesheetTimeTotal)
        totalHoursWorkedLabel.scaleFont(forDataType: .timesheetTimeTotal)
        totalBreakLabel.scaleFont(forDataType: .timesheetTimeTotal)
        breakInfoButton.delegate = self
        breakInfoButton.infoType = .breakTime
        
        totalEarningsBtn.titleLabel?.scaleFont(forDataType: .timesheetEarningsTitle)
        totalEarningsAmountLabel.scaleFont(forDataType: .timesheetEarningsTitle)
        totalEarningsWarningLabel.scaleFont(forDataType: .earningsTitle)
        periodStraightTimeTitle.scaleFont(forDataType: .earningsTitle)
//        periodStraightTimeCalculations.scaleFont(forDataType: .earningsTitle)
//        periodStraightTimeSubTitle.scaleFont(forDataType: .earningsValue)
        periodOvertimeTitle.scaleFont(forDataType: .earningsTitle)
        periodOvertimeAmount.scaleFont(forDataType: .earningsValue)
        periodOvertimeInfoBtn.delegate = self
        periodOvertimeInfoBtn.infoType = .overtime
        
        summaryContentView.addBorder(borderColor: UIColor(named: "appSecondaryColor"),
                       borderWidth: 4.0,
                       cornerRadius: 0.0)
        earningsContentView.addBorder(borderColor: UIColor(named: "appSecondaryColor"),
                                      borderWidth: 4.0,
                                      cornerRadius: 0.0)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        periodView.isAccessibilityElement = false
        periodView.accessibilityElements = [periodLabel as Any, prevPeriodBtn as Any, nextPeriodBtn as Any]
        prevPeriodBtn.accessibilityLabel = "prev_period".localized
        nextPeriodBtn.accessibilityLabel = "next_period".localized
        
        totalEarningsBtn.accessibilityHint = "total_Earnings_expand_hint".localized
        
        totalTitleLabel.accessibilityLabel = "period_total".localized
    }
    
    func displayInfo() {
        title = "timesheet".localized
        
        enterTimeTitleLabel.text = "time_entries".localized
        headingDayLabel.text = "day".localized
        headingTotalHoursLabel.text = "total_worked_hours".localized
        headingTotalBreakLabel.text = "total_break_hours".localized
        totalTitleLabel.text = "total".localized
        
        summaryTitleLabel.text = "summary".localized
        totalTitleLabel.text = "total".localized
        totalBreakLabel.text = "overtime".localized
        
        earningsTitleLabel.text = "earnings".localized
        totalEarningsBtn.setTitle("total_earning".localized, for: .normal)
        
        timesheetViewModel.updatePeriod()
        displayPeriodInfo()
    }
    
    func displayPeriodInfo() {
        periodLabel.text = timesheetViewModel.currentPeriod?.title
        timeTableView.reloadData()
        
        self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        
        UIView.animate(withDuration: 0, animations: {
            self.timeTableView.layoutIfNeeded()
        }) { (complete) in
            self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        }

        displayTotals()
    }
    
    func displayTotals() {
        

        totalHoursWorkedLabel.text = timesheetViewModel.totalHoursTime()
        totalBreakLabel.text = timesheetViewModel.totalBreakTime()
        
        let hoursWorkedAccessibilityLabel = "period_total_hours_worked".localized + (totalHoursWorkedLabel.text ?? "")
        totalHoursWorkedLabel.accessibilityLabel = hoursWorkedAccessibilityLabel

        let hoursBreakAccessibilityLabel = "period_total_hours_break".localized + (totalBreakLabel.text ?? "")
        totalBreakLabel.accessibilityLabel = hoursBreakAccessibilityLabel

        
        timesheetViewModel.updateWorkWeeks()
        displaySummary()
        displayEarnings()
    }
    
    func displaySummary() {
        refreshSummary()
    }
    
    func displayEarnings() {
        totalEarningsAmountLabel.text = timesheetViewModel.totalEarningsStr
        if timesheetViewModel.isBelowMinimumWage() {
            totalEarningsWarningLabel.text = "err_title_minimum_wage".localized
        } else if timesheetViewModel.isBelowSalaryWeeklyWage() {
            totalEarningsWarningLabel.text = "err_title_minimum_weekly_wage".localized
        }
        else {
            totalEarningsWarningLabel.text = ""
        }
        refreshEarnings()
    }

    func displayPeriodEarnings() {
        if earningsCollapsed {
            periodStraightTimeEarningsStackView.isHidden = true
            periodOvertimeEarningsStackView.isHidden = true
            periodEarningsStackView.removeArrangedSubview(periodStraightTimeEarningsStackView)
            periodEarningsStackView.removeArrangedSubview(periodOvertimeEarningsStackView)
            periodEarningsStackView.isHidden = true
        }
        else {
            periodStraightTimeEarningsStackView.isHidden = false
            periodOvertimeEarningsStackView.isHidden = false
            periodEarningsStackView.insertArrangedSubview(periodStraightTimeEarningsStackView, at: 0)
            periodEarningsStackView.isHidden = false
            periodStraightTimeTitle.text = "straight_earnings".localized
            periodStraightTimeAmount.text = timesheetViewModel.currentPeriod?.straightTimeAmountStr
            
            if timesheetViewModel.currentEmploymentModel?.overtimeEligible ?? false {
                periodEarningsStackView.insertArrangedSubview(periodOvertimeEarningsStackView, at: 1)
                periodOvertimeTitle.text = "overtime_pay".localized
                periodOvertimeAmount.text = timesheetViewModel.periodOvertimeAmountStr
            }
            else {
                periodOvertimeEarningsStackView.isHidden = true
                periodOvertimeTitle.text = ""
                periodOvertimeAmount.text = ""
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "enterTime",
            let navVC = segue.destination as? UINavigationController,
            let enterTimeVC = navVC.topViewController as? EnterTimeViewController,
            let currentDate = sender as? Date {
                enterTimeVC.enterTimeViewModel = timesheetViewModel.createEnterTimeViewModel(for: currentDate)
                enterTimeVC.timeSheetModel = timesheetViewModel
                enterTimeVC.delegate = self
        }
    }
    
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.periodLabel.isUserInteractionEnabled = true
        self.periodLabel.addGestureRecognizer(labelTap)
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        self.timePickerVC.sourceView = (periodLabel)
        self.timePickerVC.delegate = self
        self.timePickerVC.pickerMode = .date
        showPopup(popupController: self.timePickerVC, sender: periodLabel)
    }
    
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        return
    }
    
    func donePressed() {
        timeChanged(sourceView: self.timePickerVC.sourceView, datePicker: self.timePickerVC.datePicker)
        timesheetViewModel.updatePeriod(currentDate: (timePickerVC.datePicker.date))
        displayPeriodInfo()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: periodLabel)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func prevNextClick(_ sender: Any) {
        timesheetViewModel.nextPeriod(direction: .backward)
        displayPeriodInfo()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: periodLabel)
    }
    
    @IBAction func nextPeriodClick(_ sender: Any) {
        timesheetViewModel.nextPeriod(direction: .forward)
        displayPeriodInfo()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: periodLabel)
    }
    
    @IBAction func earningsToggle(_ sender: Any) {
        earningsCollapsed = !earningsCollapsed
    }
    
    func refreshSummary() {
        summaryTableView.reloadData()
        UIView.animate(withDuration: 0, animations: {
            self.summaryTableView.layoutIfNeeded()
        }) { (complete) in
            self.summaryTableViewHeightConstraint.constant = self.summaryTableView.contentSize.height
        }
    }

    func refreshEarnings() {
        displayPeriodEarnings()

        earningsTableView.reloadData()
        UIView.animate(withDuration: 0, animations: {
            self.earningsTableView.layoutIfNeeded()
        }) { (complete) in
            self.earningsTableViewHeightConstraint.constant = self.earningsTableView.contentSize.height
        }
    }
}

//MARK : Actions
extension TimesheetViewController {
    
    @objc fileprivate func infoClicked(sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = " "
        navigationItem.backBarButtonItem = backItem
        
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    
    @objc fileprivate func profileClicked(sender: Any?) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
}


//MARK : TableView DataSource Delegate
extension TimesheetViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let numSections: Int
        if tableView == timeTableView {
            numSections = 1
        }
        else if tableView == summaryTableView {
            numSections = timesheetViewModel.numberOfWorkWeeks
        }
        else if tableView == earningsTableView && !earningsCollapsed {
            numSections = timesheetViewModel.numberOfWorkWeeks
        }
        else {
            numSections = 0
        }
        
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numRows: Int = 0
       
        if tableView == timeTableView {
            numRows = timesheetViewModel.currentPeriod?.numberOfDays() ?? 0
        }
        else if tableView == summaryTableView {
            numRows = 1
        }
        else if tableView == earningsTableView {
            if let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: section), (!workWeekViewModel.isCollapsed || Util.isVoiceOverRunning) {
                numRows = 1
            }
        }
        
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        
        if tableView == timeTableView {
            let hourlyCell = tableView.dequeueReusableCell(withIdentifier: HourlyTimeTableViewCell.reuseIdentifier) as! HourlyTimeTableViewCell
            
            configure(cell: hourlyCell, at: indexPath)
            cell = hourlyCell
        }
        else if tableView == summaryTableView {
            let summaryCell = tableView.dequeueReusableCell(withIdentifier: SummaryTableViewCell.reuseIdentifier) as! SummaryTableViewCell
            
            configure(cell: summaryCell, at: indexPath)
            cell = summaryCell
        }
        else {
            let earningsCell = tableView.dequeueReusableCell(withIdentifier: EarningsTableViewCell.reuseIdentifier) as! EarningsTableViewCell
            
            configure(cell: earningsCell, at: indexPath)
            cell = earningsCell
        }
        return cell
    }
        
    func configure(cell: HourlyTimeTableViewCell, at indexPath: IndexPath) {
        cell.currentDate = timesheetViewModel.currentPeriod?.date(at: indexPath.row)
        cell.workedHours = timesheetViewModel.totalHoursTime(forDate: (cell.currentDate!))
        cell.breakHours = timesheetViewModel.totalBreakTime(forDate: (cell.currentDate!))
    }
    
    func configure(cell: SummaryTableViewCell, at indexPath: IndexPath) {
        cell.totalValueLabel.text = timesheetViewModel.hoursWorked(workWeek: indexPath.section)

        if timesheetViewModel.currentEmploymentModel?.overtimeEligible ?? false {
            cell.totalOvertimeLabel.text = timesheetViewModel.overTimeHours(workWeek: indexPath.section)
            cell.ovetimeHoursStackView.isHidden = false
            cell.totalOvertimeLabel.isHidden = false
            cell.totalOvertimeTitleLabel.isHidden = false
        }
        else {
            cell.ovetimeHoursStackView.isHidden = true
            cell.totalOvertimeLabel.isHidden = true
            cell.totalOvertimeTitleLabel.isHidden = true
        }
    }
    
    func configure(cell: EarningsTableViewCell, at indexPath: IndexPath) {
        let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: indexPath.section)
        
        cell.workWeekViewModel = workWeekViewModel
        cell.regularRateInfoBtn.delegate = self
        cell.overtimeInfoBtn.delegate = self
    }
}

//MARK : TableView DataSource Delegate
extension TimesheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard timesheetViewModel.currentEmploymentModel != nil else {
            let errMsg: String
            if timesheetViewModel.userProfileModel.isProfileEmployer {
                errMsg = "err_add_employee".localized
            }
            else {
                errMsg = "err_add_employer".localized
            }
            
            displayError(message: errMsg, title: "")
            return
        }

        guard let currentDate = timesheetViewModel.currentPeriod?.date(at: indexPath.row) else {
            return
        }
        
        performSegue(withIdentifier: "enterTime", sender: currentDate)
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "Work Week\(week+1): \(workWeekViewModel.title)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == summaryTableView {
            let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: section)
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SummaryTableViewHeaderView.reuseIdentifier) as? SummaryTableViewHeaderView
                else { return nil }
            
            headerView.section = section
            headerView.workWeekViewModel = workWeekViewModel
            return headerView
        }
        else if tableView == earningsTableView {
            let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: section)
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: EarningsTableViewHeaderView.reuseIdentifier) as? EarningsTableViewHeaderView
                else { return nil }
            
            headerView.section = section
            headerView.workWeekViewModel = workWeekViewModel
            headerView.delegate = self
            return headerView
        }


        return nil
    }
    
}

extension TimesheetViewController: EarningsHeaderViewDelegate {
    func sectionHeader(_ sectionHeader: EarningsTableViewHeaderView, toggleExpand section: Int) {
        let workWeekViewModel = timesheetViewModel.workWeekViewModel(at: section)
        
        workWeekViewModel!.isCollapsed = !workWeekViewModel!.isCollapsed
        
        earningsTableView.reloadSections([section], with: .bottom)
        
        self.earningsTableViewHeightConstraint.constant = self.earningsTableView.contentSize.height

        earningsTableView.beginUpdates()
        earningsTableView.endUpdates()
        
        UIView.animate(withDuration: 0, animations: {
            self.earningsTableView.setNeedsLayout()
            self.earningsTableView.layoutIfNeeded()
        }) { (complete) in
            self.earningsTableViewHeightConstraint.constant = self.earningsTableView.contentSize.height
        }
    }
}


// MARK: Toolbar Actions
extension TimesheetViewController {
    
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
}

extension TimesheetViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

extension TimesheetViewController: EnterTimeViewControllerDelegate {
    func didEnterTime(enterTimeModel: EnterTimeViewModel?) {
//        let annnouncementMsg = NSLocalizedString("save_time_entry", comment: "Saved time for")
//        
//        let announcementStr = String(format: annnouncementMsg, enterTimeModel?.title ?? "")
//        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)
//
        let selectedIndexPath = timeTableView.indexPathForSelectedRow
        displayPeriodInfo()
        
        if Util.isVoiceOverRunning,
            let selectedIndexPath = selectedIndexPath,
            let cell = timeTableView.cellForRow(at: selectedIndexPath) {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: cell)
        }
    }
    
    func didCancelEnterTime() {
        guard Util.isVoiceOverRunning else {return}
        
        let selectedIndexPath = timeTableView.indexPathForSelectedRow
        if let selectedIndexPath = selectedIndexPath,
            let cell = timeTableView.cellForRow(at: selectedIndexPath) {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: cell)
        }
    }
}
