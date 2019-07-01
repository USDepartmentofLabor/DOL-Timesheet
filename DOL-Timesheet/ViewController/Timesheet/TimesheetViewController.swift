//
//  TimesheetViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import MessageUI


protocol TimesheetViewControllerDelegate: class {
    func didUpdateUser()
    func didUpdateEmploymentInfo()
    func didEnterTime()
}

class TimesheetViewController: UIViewController {

    @IBOutlet weak var marqueeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    
    @IBOutlet weak var employeeEmployerLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!

    @IBOutlet weak var selectUserDropDownView: DropDownView!
    @IBOutlet weak var periodView: UIView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var prevPeriodBtn: UIButton!
    @IBOutlet weak var nextPeriodBtn: UIButton!
    
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
    
    var earningsCollapsed: Bool = true {
        didSet {
            let img: UIImage
            let accessibilityHint: String
            if earningsCollapsed {
                img = #imageLiteral(resourceName: "collape")
                accessibilityHint = NSLocalizedString("total_Earnings_expand_hint", comment: "Tap to Expand Total")
            }
            else {
                img = #imageLiteral(resourceName: "expand")
                accessibilityHint = NSLocalizedString("total_Earnings_collapse_hint", comment: "Tap to collapse Total")
            }
            totalEarningsBtn.setImage(img, for: .normal)
            totalEarningsBtn.accessibilityHint = accessibilityHint
            refreshEarnings()
        }
    }
    
    // Earnings View
    @IBOutlet weak var earningsContentView: UIView!
    
    var viewModel: TimesheetViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TimesheetViewModel()
        setupView()
        displayInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timeTableviewHeightConstraint.constant = timeTableView.contentSize.height
        earningsTableViewHeightConstraint.constant = earningsTableView.contentSize.height
        summaryTableViewHeightConstraint.constant = summaryTableView.contentSize.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        guard let viewModel = viewModel, viewModel.userProfileExists else {
            performSegue(withIdentifier: "setupProfile", sender: nil)
            return
        }

//        timeTableviewHeightConstraint.constant = timeTableView.contentSize.height
    }
    
    func setupView() {
        title = "Timesheet"
        
        let infoItem = UIBarButtonItem.infoButton(target: self, action: #selector(infoClicked(sender:)))
        navigationItem.rightBarButtonItem = infoItem
        
        let useNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(userBtnClick(_:)))
        useNameTapGesture.cancelsTouchesInView = false
        selectUserDropDownView.addGestureRecognizer(useNameTapGesture)

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

        editBtn.titleLabel?.scaleFont(forDataType: .actionButton)
        userNameLabel.scaleFont(forDataType: .headingTitle)
        paymentTypeLabel.scaleFont(forDataType: .timesheetPaymentTypeTitle)
        employeeEmployerLabel.scaleFont(forDataType: .timesheetSectionTitle)
        selectUserDropDownView.titleLabel.scaleFont(forDataType: .timesheetSelectedUser)
        selectUserDropDownView.titleLabel.textColor = UIColor(named: "darkTextColor")
        periodLabel.scaleFont(forDataType: .timesheetPeriod)
        headingDayLabel.scaleFont(forDataType: .columnHeader)
        headingTotalHoursLabel.scaleFont(forDataType: .columnHeader)
        headingTotalBreakLabel.scaleFont(forDataType: .columnHeader)
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
        
        setupAceessibility()
    }
    
    func setupAceessibility() {
        periodView.isAccessibilityElement = false
        periodView.accessibilityElements = [periodLabel as Any, prevPeriodBtn as Any, nextPeriodBtn as Any]
        prevPeriodBtn.accessibilityLabel = NSLocalizedString("prev_period", comment: "Previuos Period")
        nextPeriodBtn.accessibilityLabel = NSLocalizedString("next_period", comment: "Next Period")
        
        totalEarningsBtn.accessibilityHint = NSLocalizedString("total_Earnings_expand_hint", comment: "Tap to view Details")
    }
    
    func displayInfo() {

        let profileUser = viewModel?.userProfileModel.profileModel.currentUser
        userNameLabel.text = profileUser?.name
        
        let profileImage = profileUser?.image?.normalizedImage() ?? #imageLiteral(resourceName: "profile")
        
        let profileBtn = UIButton(type: .custom)
        profileBtn.setBackgroundImage(profileImage, for: .normal)
        profileBtn.clipsToBounds = true
        profileBtn.contentMode = .scaleAspectFill
        profileBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        profileBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileBtn.addBorder(borderColor: .white, borderWidth: 0.5, cornerRadius: profileBtn.bounds.size.width / 2)

        profileBtn.addTarget(self, action: #selector(profileClicked(sender:)), for: UIControl.Event.touchDown)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileBtn)

        if viewModel?.userProfileModel.isProfileEmployer ?? false {
            employeeEmployerLabel.text = NSLocalizedString("employee", comment: "Employee")
            selectUserDropDownView.accessibilityHint = NSLocalizedString("employee_user_hint", comment: "Tap To Select Employee")
        }
        else {
            employeeEmployerLabel.text = NSLocalizedString("employer", comment: "Employer")
            selectUserDropDownView.accessibilityHint = NSLocalizedString("employer_user_hint", comment: "Tap To Select Employer")
        }
        displayEmploymentInfo()
    }

    func displayEmploymentInfo() {
        let employmentModel =  viewModel?.currentEmploymentModel

        if employmentModel == nil {
            let addUserTitle = viewModel?.userProfileModel.addNewUserTitle
            selectUserDropDownView.title = addUserTitle ?? ""
        }
        else {
            selectUserDropDownView.title = viewModel?.selectedUserName ?? ""
        }
        
        viewModel?.updatePeriod()
        paymentTypeLabel.text = employmentModel?.currentPaymentTypeTitle ?? ""
        displayPeriodInfo()
    }
    
    func displayPeriodInfo() {
        periodLabel.text = viewModel?.currentPeriod?.title
        timeTableView.reloadData()
        
        UIView.animate(withDuration: 0, animations: {
            self.timeTableView.layoutIfNeeded()
        }) { (complete) in
            self.timeTableviewHeightConstraint.constant = self.timeTableView.contentSize.height
        }

        displayTotals()
    }
    
    func displayTotals() {
        guard let viewModel = viewModel else {
            return
        }

        totalHoursWorkedLabel.text = viewModel.totalHoursTime()
        totalBreakLabel.text = viewModel.totalBreakTime()

        viewModel.updateWorkWeeks()
        displaySummary()
        displayEarnings()
    }
    
    func displaySummary() {
        refreshSummary()
    }
    
    func displayEarnings() {
        guard let viewModel = viewModel else {
            return
        }
        
        totalEarningsAmountLabel.text = viewModel.totalEarningsStr
        if viewModel.isBelowMinimumWage() {
            totalEarningsWarningLabel.text = NSLocalizedString("err_title_minimum_wage", comment: "Below MinimumWage").capitalized
//            marqueeLabel.text = NSLocalizedString("err_title_minimum_wage", comment: "Below MinimumWage").capitalized
            
//            UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//                self.marqueeLabel.center = CGPoint(x: 0-self.marqueeLabel.bounds.size.width/2, y: self.marqueeLabel.center.y)
//            }, completion:  { _ in })
        }
        else {
            totalEarningsWarningLabel.text = ""
            marqueeLabel.text = ""
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
            periodStraightTimeTitle.text = NSLocalizedString("straight_earnings", comment: "Straight Time Earnings")
            periodStraightTimeAmount.text = viewModel?.currentPeriod?.straightTimeAmountStr
            
            if viewModel?.currentEmploymentModel?.overtimeEligible ?? false {
                periodEarningsStackView.insertArrangedSubview(periodOvertimeEarningsStackView, at: 1)
                periodOvertimeTitle.text = NSLocalizedString("overtime", comment: "Overtime")
                periodOvertimeAmount.text = viewModel?.periodOvertimeAmountStr
            }
            else {
                periodOvertimeEarningsStackView.isHidden = true
                periodOvertimeTitle.text = ""
                periodOvertimeAmount.text = ""
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "setupProfile",
            let navVC = segue.destination as? UINavigationController,
            let introVC = navVC.topViewController as? IntroductionViewController {
            introVC.delegate = self
        }
        else if segue.identifier == "showProfile",
            let navVC = segue.destination as? UINavigationController,
            let profileVC = navVC.topViewController as? SetupProfileViewController,
            let viewModel = viewModel {
            profileVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
            profileVC.delegate = self
        }
        else if segue.identifier == "manageUsers",
            let navVC = segue.destination as? UINavigationController,
            let manageUserVC = navVC.topViewController as? ManageUsersViewController,
            let viewModel = viewModel {
            manageUserVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
            manageUserVC.delegate = self
        }
        else if segue.identifier == "addEmploymentInfo",
            let navVC = segue.destination as? UINavigationController,
            let employmentInfoVC = navVC.topViewController as? EmploymentInfoViewController,
            let viewModel = viewModel {
            employmentInfoVC.viewModel = viewModel.userProfileModel.newTempEmploymentModel()
            employmentInfoVC.delegate = self
        }
        else if segue.identifier == "enterTime",
            let navVC = segue.destination as? UINavigationController,
            let enterTimeVC = navVC.topViewController as? EnterTimeViewController,
            let currentDate = sender as? Date,
            let viewModel = viewModel {
                enterTimeVC.viewModel = viewModel.createEnterTimeViewModel(forDate: currentDate)
                enterTimeVC.delegate = self
        }
    }
    
    @IBAction func userBtnClick(_ sender: Any) {
        guard let userProfileModel = viewModel?.userProfileModel else { return }
        
        let users: [User]? = userProfileModel.employmentUsers
        guard users?.count ?? 0 > 0 else {
            addNewUser()
            return
        }
        
        let newRowTitle: String = userProfileModel.addNewUserTitle
        let vc = OptionsListViewController(options: users!,
                                           title: "", addRowTitle: newRowTitle)
        vc.didSelect = { [weak self] (popVC: UIViewController, user: User?) in
            popVC.dismiss(animated: true, completion: nil)
            guard let strongSelf = self else { return }
            if let user = user {
                strongSelf.selectUserDropDownView.title = user.title
                strongSelf.setCurrentUser(user: user)
            }
            else {
                strongSelf.addNewUser()
            }
        }
        
        showPopup(popupController: vc, sender: selectUserDropDownView)
    }
    
    func setCurrentUser(user: User) {
        viewModel?.setCurrentEmploymentModel(for: user)
        displayEmploymentInfo()
    }
    
    func addNewUser() {
        performSegue(withIdentifier: "addEmploymentInfo", sender: self)
    }

    @IBAction func prevNextClick(_ sender: Any) {
        viewModel?.nextPeriod(direction: .backward)
        displayPeriodInfo()
    }
    
    @IBAction func nextPeriodClick(_ sender: Any) {
        viewModel?.nextPeriod(direction: .forward)
        displayPeriodInfo()
    }
    
    @IBAction func contactWHDClick(_ sender: Any) {
        contactWHD()
    }
    
    @IBAction func earningsToggle(_ sender: Any) {
        earningsCollapsed = !earningsCollapsed
    }
    
    @IBAction func exportClicked(_ sender: Any) {
        export()
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
            numSections = viewModel?.numberOfWorkWeeks ?? 0
        }
        else if tableView == earningsTableView && !earningsCollapsed {
            numSections = viewModel?.numberOfWorkWeeks ?? 0
        }
        else {
            numSections = 0
        }
        
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let viewModel = viewModel else {
            return 0
        }
        
        var numRows: Int = 0
       
        if tableView == timeTableView {
            numRows = viewModel.currentPeriod?.numberOfDays() ?? 0
        }
        else if tableView == summaryTableView {
            numRows = 1
        }
        else if tableView == earningsTableView {
            if let workWeekViewModel = viewModel.workWeekViewModel(at: section), (!workWeekViewModel.isCollapsed || Util.isVoiceOverRunning) {
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
        guard let viewModel = viewModel else {
            return
        }

        cell.currentDate = viewModel.currentPeriod?.date(at: indexPath.row)
        cell.breakHoursLabel.text = viewModel.totalBreakTime(forDate: (cell.currentDate!))
        cell.workedHoursLabel.text = viewModel.totalHoursTime(forDate: (cell.currentDate!))
    }
    
    func configure(cell: SummaryTableViewCell, at indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }
        
        cell.totalValueLabel.text = viewModel.hoursWorked(workWeek: indexPath.section)
        cell.totalOvertimeLabel.text = viewModel.overTimeHours(workWeek: indexPath.section)
    }
    
    func configure(cell: EarningsTableViewCell, at indexPath: IndexPath) {
        guard let workWeekViewModel = viewModel?.workWeekViewModel(at: indexPath.section) else {
            return
        }
        
        cell.viewModel = workWeekViewModel
        cell.overtimeInfoBtn.delegate = self
    }
}

//MARK : TableView DataSource Delegate
extension TimesheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }

        guard viewModel.currentEmploymentModel != nil else {
            let errMsg: String
            if viewModel.userProfileModel.isProfileEmployer {
                errMsg = NSLocalizedString("err_add_employee", comment: "")
            }
            else {
                errMsg = NSLocalizedString("err_add_employer", comment: "")
            }
            
            displayError(message: errMsg, title: "")
            return
        }

        guard let currentDate = viewModel.currentPeriod?.date(at: indexPath.row) else {
            return
        }
        
        performSegue(withIdentifier: "enterTime", sender: currentDate)
//        let destVC = EnterTimeViewController.instantiateFromStoryboard()
//        destVC.viewModel = viewModel.createEnterTimeViewModel(forDate: currentDate)
//
//        present(UINavigationController(rootViewController: destVC), animated: true, completion: nil)
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if tableView == summaryTableView {
//            return titleForWorkWeek(week: section)
//        }
//
//        return nil
//    }
//
    func titleForWorkWeek(week: Int) -> String? {
        guard let workWeekViewModel = viewModel?.workWeekViewModel(at: week) else {
            return nil
        }
        
        return "Work Week\(week+1): \(workWeekViewModel.title)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == summaryTableView {
            guard let workWeekViewModel = viewModel?.workWeekViewModel(at: section) else {
                return nil
            }
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SummaryTableViewHeaderView.reuseIdentifier) as? SummaryTableViewHeaderView
                else { return nil }
            
            headerView.section = section
            headerView.viewModel = workWeekViewModel
            return headerView
        }
        else if tableView == earningsTableView {
            guard let workWeekViewModel = viewModel?.workWeekViewModel(at: section) else {
                return nil
            }
            
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: EarningsTableViewHeaderView.reuseIdentifier) as? EarningsTableViewHeaderView
                else { return nil }
            
            headerView.section = section
            headerView.viewModel = workWeekViewModel
            headerView.delegate = self
            return headerView
        }


        return nil
    }
    
}

extension TimesheetViewController: EarningsHeaderViewDelegate {
    func sectionHeader(_ sectionHeader: EarningsTableViewHeaderView, toggleExpand section: Int) {
        guard let workWeekViewModel = viewModel?.workWeekViewModel(at: section)  else {
            return
        }
        
        workWeekViewModel.isCollapsed = !workWeekViewModel.isCollapsed
        
        earningsTableView.reloadSections([section], with: .automatic)
        earningsTableView.beginUpdates()
        earningsTableView.endUpdates()
        
        UIView.animate(withDuration: 0, animations: {
            self.earningsTableView.layoutIfNeeded()
        }) { (complete) in
            self.earningsTableViewHeightConstraint.constant = self.earningsTableView.contentSize.height
        }
    }
}


// MARK: Toolbar Actions
extension TimesheetViewController {
    func contactWHD() {
        let resourcesVC = ResourcesViewController.instantiateFromStoryboard()
        navigationController?.pushViewController(resourcesVC, animated: true)
    }
    
    func export() {
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

extension TimesheetViewController: TimesheetViewControllerDelegate {
    func didUpdateUser() {
        displayInfo()
    }
    func didUpdateEmploymentInfo() {
        displayEmploymentInfo()
    }
    
    func didEnterTime() {
        displayPeriodInfo()
    }
}
