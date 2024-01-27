//
//  TimesheetSoftenViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 1/19/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit
import MessageUI

class TimesheetSoftenViewController: UIViewController, TimeViewDelegate, TimePickerProtocol {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var employmentPopup: UIButton!
    @IBOutlet weak var payPeriodButton: UIButton!
    @IBOutlet weak var payPeriodDatePicker: UIDatePicker!
    @IBOutlet weak var payPeriodHeightConstraint: NSLayoutConstraint!
  
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var timeTableviewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    var viewModel: TimesheetViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
       // self.setupLabelTap()
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

        return viewModel?.currentPeriod?.numberOfDays() ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGray5

        let titleLabel = UILabel()
        let sectionDate = viewModel?.currentPeriod?.date(at: section)
        titleLabel.text = "\(sectionDate?.formattedWeekday ?? "") \(sectionDate?.formattedDate ?? "")".uppercased() // Customize the header text
        titleLabel.textColor = UIColor(named: "darkTextColor") // Customize the text color
        titleLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 30) // Adjust the frame as needed
        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)

        headerView.addSubview(titleLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionDate = viewModel?.currentPeriod?.date(at: section),
              let viewModel = viewModel,
              let dateLog = viewModel.currentEmploymentModel?.employmentInfo.log(forDate: sectionDate),
              let count = dateLog.timeLogs?.count
        else { return 0 }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        
        let sectionDate = viewModel?.currentPeriod?.date(at: indexPath.section)
        let timeEntryViewModel: EnterTimeViewModel = (viewModel?.createEnterTimeViewModel(for: sectionDate!))!
        var timeLog = timeEntryViewModel.timeLogs![indexPath.row]
        
        let hourlyCell = tableView.dequeueReusableCell(withIdentifier: TimeEntryViewCell.reuseIdentifier) as! TimeEntryViewCell

        hourlyCell.configure(timeLog: timeLog)
        
        cell = hourlyCell
        
        return cell
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
