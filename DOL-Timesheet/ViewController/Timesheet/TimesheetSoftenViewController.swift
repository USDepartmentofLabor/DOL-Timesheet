//
//  TimesheetSoftenViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 1/19/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit
import MessageUI


struct PayPeriodSummary {
    let name: String
    let value1: String
    let value2: String
}

class TimesheetSoftenViewController: UIViewController, TimeViewDelegate, TimePickerProtocol {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var employmentView: UIView!
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var employmentPopup: UIButton!
    
    @IBOutlet weak var payPeriodView: UIView!
    @IBOutlet weak var payPeriodTitleLabel: UILabel!
    @IBOutlet weak var payPeriodButton: UIButton!
    @IBOutlet weak var payPeriodDatePicker: UIDatePicker!
    @IBOutlet weak var payPeriodHeightConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var timeTableviewHeightConstraint: NSLayoutConstraint!
    
    var timePickerVC = TimePickerViewController.instantiateFromStoryboard()


    @IBOutlet weak var scrollView: UIScrollView!
    var timesheetViewModel: TimesheetViewModel?
    var payPeriodSummaryData: [PayPeriodSummary] = []
    var selectedTimeLog = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        timesheetViewModel = TimesheetViewModel()
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
        
        employmentTitleLabel.text = "employer".localized
        if timesheetViewModel?.currentEmploymentModel?.isProfileEmployer ?? false {
            employmentTitleLabel.text = "employee".localized
        }
        
        payPeriodTitleLabel.text = "pay_period".localized
        
        payPeriodHeightConstraint.constant = 0
        
        
        timeTableView.register(UINib(nibName: TimeEntryViewCell.nibName, bundle: nil), forCellReuseIdentifier: TimeEntryViewCell.reuseIdentifier)
        timeTableView.rowHeight = UITableView.automaticDimension
        timeTableView.estimatedRowHeight = 40
        
        employmentView.layer.cornerRadius = Style.CORNER_ROUNDING
        employmentView.clipsToBounds = true
        
        payPeriodView.layer.cornerRadius = Style.CORNER_ROUNDING
        payPeriodView.clipsToBounds = true
        
//        timeTableView.backgroundColor = UIColor.systemGray5
//        2C2C2E dark
//        E5E5EA light
    }
    
    func displayInfo() {
        timesheetViewModel?.updatePeriod()
        setupEmploymentPopupButton()
        displayPeriodInfo()
    }
    
    func setupEmploymentPopupButton(){
        let optionClosure = {(action : UIAction) in
            print(action.title)
        }
        
        var menuActions: [UIAction] = []
        
        guard let userProfileModel = timesheetViewModel?.userProfileModel else { return }
        
        let users: [User] = userProfileModel.employmentUsers
        guard users.count > 0 else {
            return
        }
                
        for user in users {
            let action = UIAction(title: user.name!, handler: {_ in
                self.setCurrentUser(user: user)
            })
            menuActions.append(action)
        }
        let newUserAction = UIAction(title: userProfileModel.addNewUserTitle, handler: {_ in
            self.addNewUser()
        })
        
        menuActions.append(newUserAction)
        
        employmentPopup.menu = UIMenu(children : menuActions)
        employmentPopup.showsMenuAsPrimaryAction = true
        employmentPopup.changesSelectionAsPrimaryAction = true
    }
    
    func displayPeriodInfo() {
        periodLabel.text = timesheetViewModel?.currentPeriod?.title
        payPeriodSummaryData = []
        
        
        let hoursWorked: String = timesheetViewModel!.totalHoursTime()
        payPeriodSummaryData.append(PayPeriodSummary(name: "total_hours_worked".localized, value1: "", value2: hoursWorked))
        
        let numDays = timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0
        
        if let timeSheetModel = timesheetViewModel,
           let currentPeriod = timeSheetModel.currentPeriod {
            
            timeSheetModel.currentEmploymentModel?.hourlyRates?.forEach { rate in
                var totalRateHours = 0
                for dayIndex in 0..<numDays {
                    let sectionDate = currentPeriod.date(at: dayIndex)
                    totalRateHours += timeSheetModel.totalRateHoursTime(forRate: rate, forDate: sectionDate)
                }
                let hrsMinStr: String = Date.secondsToHoursMinutes(seconds: Double(totalRateHours))

                payPeriodSummaryData.append(PayPeriodSummary(name: rate.title, value1: "", value2: hrsMinStr))
            }
        }
        
        let breakTimeHours: String = timesheetViewModel!.totalBreakTime()
        payPeriodSummaryData.append(PayPeriodSummary(name: "break_hours".localized, value1: "", value2: breakTimeHours))
        
        
        if let timeSheetModel = timesheetViewModel {
            var totalOvertime: Double = 0.0
            for weekIndex in 0..<timeSheetModel.numberOfWorkWeeks {
                totalOvertime += timeSheetModel.overTimeHours(workWeek: weekIndex)
            }
            
            let overtimeStr: String = Date.secondsToHoursMinutes(seconds: totalOvertime)
            payPeriodSummaryData.append(PayPeriodSummary(name: "overtime".localized, value1: "", value2: overtimeStr))
        }
        
        if numDays >= 7 {
            payPeriodSummaryData.append(PayPeriodSummary(name: "weekly_summary".localized, value1: "", value2: ""))
        }
        timeTableView.reloadData()
        
//        self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        
        UIView.animate(withDuration: 0, animations: {
            self.timeTableView.layoutIfNeeded()
        }) { (complete) in
            self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
            self.scrollView.contentSize = CGSize(
                width: self.scrollView.frame.size.width,
                height: self.timeTableView.contentSize.height + self.payPeriodDatePicker.frame.origin.y + self.payPeriodDatePicker.frame.size.height+25
            )
        }

       // displayTotals()
    }

    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        return
    }
    
    @IBAction func payPeriodPressed(_ sender: Any) {
        self.timePickerVC.sourceView = (periodLabel)
        self.timePickerVC.delegate = self
        self.timePickerVC.pickerMode = .date
        showPopup(popupController: self.timePickerVC, sender: periodLabel)
    }
    
    func donePressed() {
        timeChanged(sourceView: self.timePickerVC.sourceView, datePicker: self.timePickerVC.datePicker)
        timesheetViewModel?.updatePeriod(currentDate: (timePickerVC.datePicker.date))
        displayPeriodInfo()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: periodLabel)
        self.dismiss(animated: true, completion: nil)
    }
    
    func deleteTimeLog(indexPath: IndexPath) {
        let sectionDate = (timesheetViewModel?.currentPeriod?.date(at: indexPath.section))!
        let enterTimeViewModel = timesheetViewModel!.createEnterTimeViewModel(for: sectionDate)
        
        let timeLog = enterTimeViewModel?.timeLogs![indexPath.row]

        
        guard let safeEnterTimeViewModel = enterTimeViewModel else { return }
        safeEnterTimeViewModel.removeTimeLog(timeLog: timeLog!)
        safeEnterTimeViewModel.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterTime",
           let enterTimeVC = segue.destination as? EnterTimeSoftenViewController,
           let currentDate = sender as? Date,
           let timesheetViewModel = timesheetViewModel {
            enterTimeVC.timeSheetModel = timesheetViewModel
            
            let enterTimeViewModel = timesheetViewModel.createEnterTimeViewModel(for: currentDate)
            enterTimeVC.enterTimeViewModel = enterTimeViewModel
            
            enterTimeVC.selectedEmployment = timesheetViewModel.userProfileModel.employmentUsers.firstIndex(of: (timesheetViewModel.currentEmploymentModel?.employmentUser)!)
            
            let timeLog = enterTimeViewModel?.timeLogs![selectedTimeLog]
            
            enterTimeVC.timeLogEntry = timeLog
            
            enterTimeVC.delegate = self
        } else if segue.identifier == "weeklySummary",
           let weeklySummaryVC = segue.destination as? WeeklySummaryViewController,
           let timesheetViewModel = timesheetViewModel {
            weeklySummaryVC.timesheetViewModel = timesheetViewModel
        } else if segue.identifier == "addEmploymentInfo",
                  let navVC = segue.destination as? UINavigationController,
                  let employmentInfoVC = navVC.topViewController as? EmploymentInfoViewController,
                  let viewModel = timesheetViewModel {
                  employmentInfoVC.viewModel = viewModel.userProfileModel.newTempEmploymentModel()
                  employmentInfoVC.delegate = self
              }
    }
}

////MARK : TableView DataSource Delegate
extension TimesheetSoftenViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {

        return (timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0) + 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
//        headerView.backgroundColor = UIColor.systemGray5

        let titleLabel = UILabel()
        var sectionTitle = ""
        let numDays = timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0
        if section < numDays {
            let sectionDate = timesheetViewModel?.currentPeriod?.date(at: section)
            sectionTitle = "\(sectionDate?.formattedWeekday ?? "") \(sectionDate?.formattedDate ?? "")".uppercased()
        } else if section < numDays + 1 {
            sectionTitle = "pay_period_summary".localized.uppercased()
        } else {
            return nil
        }
        titleLabel.text = sectionTitle // Customize the header text
        titleLabel.textColor = UIColor(named: "darkTextColor") // Customize the text color
        titleLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 30) // Adjust the frame as needed
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)

        headerView.addSubview(titleLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numDays = timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0
        
        if section >= numDays + 1 {
            return 1
        } else if section >= numDays {
            return payPeriodSummaryData.count
        }
        
        guard let sectionDate = timesheetViewModel?.currentPeriod?.date(at: section),
              let safeTimesheetViewModel = timesheetViewModel,
              let dateLog = safeTimesheetViewModel.currentEmploymentModel?.employmentInfo.log(forDate: sectionDate),
              let count = dateLog.timeLogs?.count
        else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hourlyCell = tableView.dequeueReusableCell(withIdentifier: TimeEntryViewCell.reuseIdentifier) as! TimeEntryViewCell
        let numDays = timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0
        let section = indexPath.section
        let row = indexPath.row
        hourlyCell.firstItem = indexPath.row == 0
        
        if section < numDays {
            let sectionDate = timesheetViewModel?.currentPeriod?.date(at: indexPath.section)
            let timeEntryViewModel: EnterTimeViewModel = (timesheetViewModel?.createEnterTimeViewModel(for: sectionDate!))!
            let timeLog = timeEntryViewModel.timeLogs![indexPath.row]
            hourlyCell.lastItem = indexPath.row == (timeEntryViewModel.timeLogs!.count - 1)
            hourlyCell.configure(timeLog: timeLog)
            hourlyCell.rightChevronIcon.isHidden = false
            
        } else if section < numDays + 1 {
            hourlyCell.rateName.text = payPeriodSummaryData[row].name
            hourlyCell.timeFrame.text = payPeriodSummaryData[row].value1
            hourlyCell.totalTime.text = payPeriodSummaryData[row].value2
            hourlyCell.lastItem = indexPath.row == (payPeriodSummaryData.count - 1)
            hourlyCell.rightChevronIcon.isHidden = false
            if((payPeriodSummaryData.count - 1) != row){
                hourlyCell.rightChevronIcon.isHidden = true
            }
            hourlyCell.addborder()
        } else {
            hourlyCell.rateName.text = "earning_details".localized
            hourlyCell.timeFrame.text = ""
            hourlyCell.totalTime.text = timesheetViewModel?.totalEarningsStr
            hourlyCell.lastItem = true
            hourlyCell.rightChevronIcon.isHidden = false
            hourlyCell.addborder()
        }
        
       // hourlyCell.layer.cornerRadius = 10
       // hourlyCell.layer.masksToBounds = true
        
        return hourlyCell
    }
    
    func tableView(_ tableView:UITableView, editingStyleForRowAt: IndexPath) -> UITableViewCell.EditingStyle {
        let numDays = timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0
        let section = editingStyleForRowAt.section
        
        if section < numDays {
            return .delete
        }
        
        return .none
    }
    
    func tableView(_ tableView:UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        deleteTimeLog(indexPath: indexPath)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        tableView.endUpdates()
    }
}

//MARK : TableView DataSource Delegate
extension TimesheetSoftenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after selection
        
        let secondToLastSection = tableView.numberOfSections - 2
        let secondToLastRow = tableView.numberOfRows(inSection: secondToLastSection) - 1
        let numDays = timesheetViewModel?.currentPeriod?.numberOfDays() ?? 0
        
        guard let currentDate = timesheetViewModel?.currentPeriod?.date(at: indexPath.section) else {
            return
        }
        
        if indexPath.section < secondToLastRow {
            selectedTimeLog = indexPath.row
            performSegue(withIdentifier: "enterTime", sender: currentDate)
        }
        
        if numDays >= 7 {
            if indexPath.section == secondToLastSection && indexPath.row == secondToLastRow {
                performSegue(withIdentifier: "weeklySummary", sender: self)
            }
        }
//        if indexPath.section < numDays {
//            
//        } else if indexPath.section < numDays + 1 {
//            
//        }
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = timesheetViewModel?.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "Work Week\(week+1): \(workWeekViewModel.title)"
    }
    
}

//// MARK: Toolbar Actions
extension TimesheetSoftenViewController {
    
    func export(_ sender: Any) {
        guard let csvPath = timesheetViewModel?.csv() else {
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
        timesheetViewModel?.setCurrentEmploymentModel(for: user)
    }
}

extension TimesheetSoftenViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}


extension TimesheetSoftenViewController: TimeViewControllerDelegate {
    func didUpdateUser() {
        if let user = timesheetViewModel?.userProfileModel.employmentUsers.first {
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

extension TimesheetSoftenViewController: EnterTimeViewControllerDelegate {
    func didEnterTime(enterTimeModel: EnterTimeViewModel?) {
    }
    
    func didCancelEnterTime() {
        
    }
}
