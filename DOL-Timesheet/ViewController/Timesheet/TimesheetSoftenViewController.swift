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
    @IBOutlet weak var employmentPopup: UIButton!
    @IBOutlet weak var payPeriodButton: UIButton!
    @IBOutlet weak var payPeriodDatePicker: UIDatePicker!
    @IBOutlet weak var payPeriodHeightConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var timeTableviewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    var viewModel: TimesheetViewModel?
    var payPeriodSummaryData: [PayPeriodSummary] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        viewModel = TimesheetViewModel()
        setupView()
        displayInfo()
       // self.setupLabelTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayInfo()
    }
    
    func setupView() {
        
        payPeriodHeightConstraint.constant = 0
        
        
        timeTableView.register(UINib(nibName: TimeEntryViewCell.nibName, bundle: nil), forCellReuseIdentifier: TimeEntryViewCell.reuseIdentifier)
        timeTableView.rowHeight = UITableView.automaticDimension
        timeTableView.estimatedRowHeight = 40
        timeTableView.backgroundColor = UIColor.systemGray5
        
    }
    
    func displayInfo() {
        viewModel?.updatePeriod()
        setupEmploymentPopupButton()
        displayPeriodInfo()
    }
    
    func setupEmploymentPopupButton(){
        let optionClosure = {(action : UIAction) in
            print(action.title)
        }
        
        var menuActions: [UIAction] = []
        
        guard let userProfileModel = viewModel?.userProfileModel else { return }
        
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
        periodLabel.text = viewModel?.currentPeriod?.title
        payPeriodSummaryData = []
        payPeriodSummaryData.append(PayPeriodSummary(name: "Total Hours Worked", value1: "xx hrs", value2: "x min"))
        viewModel?.currentEmploymentModel?.hourlyRates?.forEach {rate in
            payPeriodSummaryData.append(PayPeriodSummary(name: rate.title, value1: "xx hrs", value2: "x min"))
        }
        payPeriodSummaryData.append(PayPeriodSummary(name: "Break Hours", value1: "xx hrs", value2: "x min"))
        payPeriodSummaryData.append(PayPeriodSummary(name: "Overtime", value1: "xx hrs", value2: "x min"))
        payPeriodSummaryData.append(PayPeriodSummary(name: "Weekly Summary", value1: "", value2: ""))
        timeTableView.reloadData()
        
//        self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        
        UIView.animate(withDuration: 0, animations: {
            self.timeTableView.layoutIfNeeded()
        }) { (complete) in
            self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.timeTableView.contentSize.height + self.payPeriodDatePicker.frame.origin.y + self.payPeriodDatePicker.frame.size.height)
        }

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
extension TimesheetSoftenViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {

        return (viewModel?.currentPeriod?.numberOfDays() ?? 0) + 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGray5

        let titleLabel = UILabel()
        var sectionTitle = ""
        let numDays = viewModel?.currentPeriod?.numberOfDays() ?? 0
        if section < numDays {
            let sectionDate = viewModel?.currentPeriod?.date(at: section)
            sectionTitle = "\(sectionDate?.formattedWeekday ?? "") \(sectionDate?.formattedDate ?? "")".uppercased()
        } else if section < numDays + 1 {
            sectionTitle = "PAY PERIOD SUMMARY"
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
        
        let numDays = viewModel?.currentPeriod?.numberOfDays() ?? 0
        
        if section >= numDays + 1 {
            return 1
        } else if section >= numDays {
            return payPeriodSummaryData.count
        }
        
        guard let sectionDate = viewModel?.currentPeriod?.date(at: section),
              let viewModel = viewModel,
              let dateLog = viewModel.currentEmploymentModel?.employmentInfo.log(forDate: sectionDate),
              let count = dateLog.timeLogs?.count
        else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hourlyCell = tableView.dequeueReusableCell(withIdentifier: TimeEntryViewCell.reuseIdentifier) as! TimeEntryViewCell
        let numDays = viewModel?.currentPeriod?.numberOfDays() ?? 0
        let section = indexPath.section
        let row = indexPath.row
        if section < numDays {
            let sectionDate = viewModel?.currentPeriod?.date(at: indexPath.section)
            let timeEntryViewModel: EnterTimeViewModel = (viewModel?.createEnterTimeViewModel(for: sectionDate!))!
            var timeLog = timeEntryViewModel.timeLogs![indexPath.row]

            hourlyCell.configure(timeLog: timeLog)
        } else if section < numDays + 1 {
            hourlyCell.rateName.text = payPeriodSummaryData[row].name
            hourlyCell.timeFrame.text = payPeriodSummaryData[row].value1
            hourlyCell.totalTime.text = payPeriodSummaryData[row].value2
        } else {
            hourlyCell.rateName.text = "Earning Details"
            hourlyCell.timeFrame.text = ""
            hourlyCell.totalTime.text = "$$$"
        }
        
        hourlyCell.layer.cornerRadius = 10
        hourlyCell.layer.masksToBounds = true
        
        return hourlyCell
    }
}

//MARK : TableView DataSource Delegate
extension TimesheetSoftenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        return
    }
    
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = viewModel?.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "Work Week\(week+1): \(workWeekViewModel.title)"
    }
    
}

//// MARK: Toolbar Actions
extension TimesheetSoftenViewController {
    
    func export(_ sender: Any) {
        guard let csvPath = viewModel?.csv() else {
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
        viewModel?.setCurrentEmploymentModel(for: user)
    }
         
}

extension TimesheetSoftenViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}


extension TimesheetSoftenViewController: TimeViewControllerDelegate {
    func didUpdateUser() {
        if let user = viewModel?.userProfileModel.employmentUsers.first {
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
