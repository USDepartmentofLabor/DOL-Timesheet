//
//  TimeCardViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
//import DropDown

protocol TimeCardDelegate: class {
    func gotoTimesheet()
}


class TimeCardViewController: UIViewController, TimeViewDelegate, TimeViewControllerDelegate, TimeCardViewControllerDelegate {
    func didUpdateUser() {
    
    }
    
    func didUpdateEmploymentInfo() {
    
    }
    
    func didUpdateLanguageChoice() {
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    
    @IBOutlet var myView: UIView!
    
    @IBOutlet weak var rateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var hoursView: UIView!
    
    @IBOutlet weak var hoursWorkedTitleLabel: UILabel!
    @IBOutlet weak var workedHoursView: UIView!
    @IBOutlet weak var workedHoursCounterLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!

    @IBOutlet weak var hoursWorkedInfoBtn: UIButton!
    @IBOutlet weak var breakViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var breakHoursTitleLabel: UILabel!
    @IBOutlet weak var breakHoursView: UIView!
    @IBOutlet weak var breakHoursCounterLabel: UILabel!
    @IBOutlet weak var breakTimeInfoLabel: UILabel!
    @IBOutlet weak var breakTimeInfoBtn: UIButton!
    
    @IBOutlet weak var actionStackView: UIStackView!
    
    @IBOutlet weak var discardButton: UIButton!
    
    @IBOutlet weak var commentsTitleLabel: UILabel!
//    @IBOutlet weak var commentsView: UIView!
//    @IBOutlet weak var commentsTextView: UITextView!
    
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var ratePopupButton: UIButton!
    @IBOutlet weak var popupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupBottomConstraint: NSLayoutConstraint!
    
    var rateOptions: [HourlyRate]?
    var selectedRate = 0
    let lighterGrey = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    
    weak var delegate: EnterTimeViewControllerDelegate?

    
    var workedHoursCounter: TimeInterval = 0 {
        didSet {
            let (hours, minutes) = Date.secondsToHoursMinutes(seconds: workedHoursCounter)
            workedHoursCounterLabel.text = String(format: "%d:%02d", hours, minutes)
            workedHoursCounterLabel.accessibilityLabel = (hoursWorkedTitleLabel.text ?? "")
            workedHoursCounterLabel.accessibilityValue =  "\(hours) hours, \(minutes) minutes"
        }
    }
    
    var breakHoursCounter: TimeInterval = 0 {
        didSet {
            let (hours, minutes) = Date.secondsToHoursMinutes(seconds: breakHoursCounter)
            breakHoursCounterLabel.text = String(format: "%d:%02d", hours, minutes)
            breakHoursCounterLabel.accessibilityLabel = (breakHoursTitleLabel.text ?? "")
            breakHoursCounterLabel.accessibilityValue =  "\(hours) hours, \(minutes) minutes"
        }
    }
    
    var viewModel: TimesheetViewModel?
    weak var timeViewControllerDelegate: TimeCardDelegate?
    var timer: Timer?
    var currentHourlyRate: HourlyRate? {
        didSet {
            ratePopupButton.setTitle(currentHourlyRate?.title ?? "", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Localizer.initialize()  
        setupNavigationBarSettings()
        setupView()
        
        if let viewControllers = self.tabBarController?.viewControllers {
            // Set titles for each tab bar item
            viewControllers[0].tabBarItem.title = "contact_us".localized
            viewControllers[1].tabBarItem.title = "timesheet".localized
            viewControllers[2].tabBarItem.title = "timecard".localized
            viewControllers[3].tabBarItem.title = "my_profile".localized
            viewControllers[4].tabBarItem.title = "info_title".localized
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Localizer.initialize()
        
        guard let viewModel = viewModel, viewModel.userProfileExists else {
            //performSegue(withIdentifier: "setupProfile", sender: nil)
            performSegue(withIdentifier: "showOnboard", sender: nil)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTimer()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        workedHoursView.dropShadow()
//        breakHoursView.dropShadow()
//    }
//
    func setupView() {
        
        ratePopupButton.layer.borderWidth = 1.0 // Set the width of the border
        ratePopupButton.layer.borderColor = lighterGrey.cgColor // Set the color of the border
        ratePopupButton.layer.cornerRadius = 10.0

        workedHoursCounterLabel.scaleFont(forDataType: .timeCounterText)
        hoursWorkedTitleLabel.scaleFont(forDataType: .nameValueTitle)
        timeInfoLabel.scaleFont(forDataType: .timecardInfoText)
//        timeInfoLabel.textColor = UIColor(named: "appSecondaryColor")
        
        timeInfoLabel.isHidden = true

       // breakHoursCounterLabel.scaleFont(forDataType: .breakTimeCounterText)
        breakHoursTitleLabel.scaleFont(forDataType: .nameValueText)
        breakTimeInfoLabel.scaleFont(forDataType: .timecardInfoText)
//        breakTimeInfoLabel.textColor = UIColor(named: "appSecondaryColor")
        
        breakHoursView.isHidden = true
        breakViewHeightConstraint.constant = 0.0
        
//        commentsTitleLabel.scaleFont(forDataType: .enterTimeTitle)
//        commentsTextView.addBorder()
        
        discardButton.layer.borderWidth = 1.0
        discardButton.layer.cornerRadius = 5.0
        discardButton.layer.borderColor = UIColor.red.cgColor

        discardButton.setTitleColor(UIColor.red, for: .normal)
        discardButton.setTitleColor(UIColor.white, for: .highlighted)
        discardButton.setTitle("discard".localized, for: .normal)
                
//        workedHoursView.bottomAnchor.constraint(equalTo: hoursView.bottomAnchor).isActive = true
        
        ratePopupButton.isHidden = false
        setupPopupButton()
            
        ratePopupButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        rateOptions = viewModel?.currentEmploymentModel?.hourlyRates
        
//        workedHoursView.addBorder()
//        breakHoursView.addBorder()
        
    }
    
    @objc func labelTapped() {
        ratePopupButton.sendActions(for: .touchUpInside)
    }
    
    func setupPopupButton(){
        ratePopupButton.isHidden = false
        rateLabel.isHidden =  false
        if let paymentType = viewModel?.currentEmploymentModel?.paymentType,
            paymentType == .salary {
            
            ratePopupButton.isHidden = true
            rateLabel.isHidden =  true
            return
        }
        self.selectedRate = 0
        let optionClosure = {(action : UIAction) in
            print(action.title)
        }
        
        var menuActions: [UIAction] = []

        guard  let options = rateOptions else {
            return
        }
                
        for (index, option) in options.enumerated() {
            let action = UIAction(title: option.title, handler: {_ in
                self.currentHourlyRate = option
                self.selectedRate = index
            })
            menuActions.append(action)
        }
        
        ratePopupButton.menu = UIMenu(children : menuActions)
        ratePopupButton.showsMenuAsPrimaryAction = true
        ratePopupButton.changesSelectionAsPrimaryAction = true
    }
    
    func displayInfo() {
        // Remove Rate if salaried employee
        
        rateLabel.text = "rate".localized
        discardButton.setTitle("discard".localized, for: .normal)

        hoursWorkedTitleLabel.text = "hours_worked".localized
        breakHoursTitleLabel.text = "break_hours".localized
        
        if let paymentType = viewModel?.currentEmploymentModel?.paymentType,
            paymentType == .salary {
            ratePopupButton.isHidden = true
            ratePopupButton.isAccessibilityElement = false
            popupBottomConstraint.priority = .init(200)
            popupHeightConstraint.priority = .init(200)
        }
        else {
            ratePopupButton.isHidden = false
            ratePopupButton.isAccessibilityElement = true
            popupBottomConstraint.priority = .init(900)
            popupHeightConstraint.priority = .init(900)
        }
        
        if let hourlyRates = viewModel?.currentEmploymentModel?.hourlyRates, hourlyRates.count > 0 {
            currentHourlyRate = hourlyRates[0]
            rateOptions = viewModel?.currentEmploymentModel?.hourlyRates
        }
        else {
            currentHourlyRate = nil
        }
        
        setupPopupButton()
        
        displayClock()
    }
    
    func displayClock() {
        let clockState = viewModel?.clockState
        if clockState == .clockedIn || clockState == .inBreak {
            startTimer()
            // display Comments
//            commentsView.isHidden = true

            
            if let hourlyRate = viewModel?.currentEmploymentModel?.employmentInfo.clock?.hourlyRate {
                currentHourlyRate = hourlyRate
            }
            discardButton.isHidden = false
            timeInfoLabel.isHidden = false
            breakTimeInfoLabel.isHidden = false
        }
        else {
            // hide Comments
//            commentsView.isHidden = true
            timeInfoLabel.text = ""
            timeInfoLabel.isHidden = true
            breakTimeInfoLabel.text = ""
            breakTimeInfoLabel.isHidden = true
            ratePopupButton.isEnabled = true
            
            discardButton.isHidden = true
        }
        
        displayLoggedTime()
        displayActions()
    }
    
    @objc func cancelClick(sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveClick(sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    func isValidHourlyRate() -> Bool {
        if let hourlyRate = viewModel?.currentEmploymentModel?.employmentInfo.clock?.hourlyRate {
            if hourlyRate.value < 0.01 {
                let alertController = UIAlertController(title: "Error",
                                                        message: "An error was detected in the hourly rate, this entry has been discarded.".localized,
                                                        preferredStyle: .alert)
                
                alertController.addAction(
                    UIAlertAction(title: "ok".localized, style: .default))
                present(alertController, animated: true)
                
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }

    @IBAction func startWorkClick(_ sender: Any) {
        discardButton.isHidden = false
        viewModel?.clock(action: .startWork, hourlyRate: currentHourlyRate, comments: nil)
        displayClock()
    }
    
    @IBAction func endWorkClick(_ sender: Any) {
        
        if !isValidHourlyRate(){
            self.discardEntry()
            return
        }
        
        if ( viewModel?.currentEmploymentModel?.employmentInfo.clock?.totalHoursWorked() ?? 0 >= 0) {
            viewModel?.clock(action: .endWork, comments: "")
  
            if let clock = viewModel?.currentEmploymentModel?.employmentInfo.clock {
                
                if !(clock.startTime?.isEqualOnlyDate(date: Date()) ?? true) {
                    let message = "warning_split_time".localized
                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "yes".localized, style: .default, handler: { [weak self] (action) in
                        guard let strongSelf = self else { return }
                        strongSelf.timeViewControllerDelegate?.gotoTimesheet()
                        strongSelf.resetClock(clock)
//                        strongSelf.discardEntry()
                    }))
                        
                    alertController.addAction(UIAlertAction(title: "no".localized, style: .cancel, handler: nil))
                    present(alertController, animated: false)
                }
                else {
                   // displayClock()
                    timeViewControllerDelegate?.gotoTimesheet()
                    resetClock(clock)
//                    self.discardEntry()
//                    performSegue(withIdentifier: "enterTime", sender: clock)
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "The time appears to be negative, maybe your clock was set backward.", preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(title: "cancel".localized, style: .cancel))
            alertController.addAction(
                UIAlertAction(title: "discard".localized, style: .destructive) { _ in
                    self.discardEntry()
            })
            present(alertController, animated: false)
        }
    }
    
    @IBAction func startBreakClick(_ sender: Any) {
        breakViewHeightConstraint.constant = 119.0
        if isValidHourlyRate() {
            viewModel?.clock(action: .startBreak, comments: "")
            breakHoursView.isHidden = false
            view.layoutSubviews()
            view.layoutIfNeeded()
            displayClock()
        } else {
            self.discardEntry()
        }
    }
    @IBAction func endBreakClick(_ sender: Any) {
        if !isValidHourlyRate() {
            self.discardEntry()
            return
        }
        breakViewHeightConstraint.constant = 0.0
        if ( viewModel?.currentEmploymentModel?.employmentInfo.clock?.totalBreakTime() ?? 0 >= 0) {
            breakHoursView.isHidden = true
            view.layoutIfNeeded()
            viewModel?.clock(action: .endBreak, comments: "")
            displayClock()
        } else {
            let alertController = UIAlertController(title: "Error", message: "The time appears to be negative, maybe your clock was set backward.", preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(title: "cancel".localized, style: .cancel))
            alertController.addAction(
                UIAlertAction(title: "discard".localized, style: .destructive) { _ in
                    self.discardEntry()
            })
            present(alertController, animated: false)
        }
    }

    @IBAction func manualEntryClick(_ sender: Any) {
        performSegue(withIdentifier: "enterTime", sender: self)
    }
    
    @IBAction func discardEntryClick(_ sender: Any) {
        let titleMsg = "discard_entry".localized
        let errorMsg = "discard_entry_confirm".localized
        
        let alertController = UIAlertController(title: titleMsg,
                                                message: errorMsg,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "discard".localized, style: .destructive) { _ in
                self.discardEntry()
        })
        present(alertController, animated: true)
    }
        
    func discardEntry() {
        breakViewHeightConstraint.constant = 0.0
        breakHoursView.isHidden = true
        discardButton.isHidden = true
        viewModel?.clock(action: .discardEntry, comments: nil)
        displayClock()
        
    }
    
    func resetClock(_ clock: PunchClock) {
        breakViewHeightConstraint.constant = 0.0
        breakHoursView.isHidden = true
        discardButton.isHidden = true
        
        let enterTimeModel = viewModel?.createEnterTimeViewModel(for: clock, hourlyRate: currentHourlyRate)
        enterTimeModel?.save()
        
        delegate?.didEnterTime(enterTimeModel: enterTimeModel)
        
        displayClock()
        
    }
    
    @IBAction func breakInfoClicked(_ sender: Any) {
        displayInfoPopup(sender, info: .breakTime)
    }
    
    @IBAction func endWorkInfoClicked(_ sender: Any) {
        displayInfoPopup(sender, info: .endTime)
    }

    
    func displayLoggedTime() {
        if let clock = viewModel?.currentEmploymentModel?.employmentInfo.clock,
            let startTime = clock.startTime {

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            let startTimeStr = dateFormatter.string(from: startTime)
            let workString = "started_work".localized
            timeInfoLabel.text = workString + startTimeStr
            
            var breakTimeStr: String = ""
            clock.breaksSorted?.forEach {
                if let startTime = $0.startTime, let endTime = $0.endTime {
                    let breakStartStr = dateFormatter.string(from: startTime)
                    let breakEndStr = dateFormatter.string(from: endTime)
                    if !breakTimeStr.isEmpty {
                        breakTimeStr.append("\n")
                    }
                    breakTimeStr.append("- Break \(breakStartStr) - \(breakEndStr)")
                }
                else if let startTime = $0.startTime {
                    let breakStartStr = dateFormatter.string(from: startTime)
                    let breakString = "started_break".localized
                    breakTimeStr.append(breakString + breakStartStr)
                }
            }
            
            breakTimeInfoLabel.text = breakTimeStr
//            commentsTextView.text = clock.comments
        }
        else {
            timeInfoLabel.text = ""
        }
//        commentsTitleLabel.text = "comments".localized
        updateTimeCounter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterTime",
            let enterTimeVC = segue.destination as? EnterTimeSoftenViewController,
            let viewModel = viewModel {
            let enterTimeModel: EnterTimeViewModel?
            if let clock = sender as? PunchClock {
                enterTimeModel = viewModel.createEnterTimeViewModel(for: clock, hourlyRate: currentHourlyRate)
            }
            else {
                enterTimeModel = viewModel.createEnterTimeViewModel(for: Date())
            }
            
            enterTimeVC.viewModel = enterTimeModel
            enterTimeVC.timeSheetModel = viewModel
            enterTimeVC.delegate = self
                       
            enterTimeVC.selectedRate = 0
            
            if let paymentType = viewModel.currentEmploymentModel?.paymentType,
                paymentType != .salary {
                enterTimeVC.selectedRate = selectedRate
            }
            
            enterTimeVC.selectedEmployment = viewModel.userProfileModel.employmentUsers.firstIndex(of: (viewModel.currentEmploymentModel?.employmentUser)!)
    
        }
        else if segue.identifier == "showUserProfile",
             let navVC = segue.destination as? UINavigationController,
             let profileVC = navVC.topViewController as? SetupProfileViewController,
             let viewModel = viewModel {
             profileVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
             profileVC.delegate = self
        }
        else if segue.identifier == "showOnboard",
            let navVC = segue.destination as? UINavigationController,
            let introVC = navVC.topViewController as? OnboardPageNavigationViewController {
            introVC.delegate = self
        }
    }
}

extension TimeCardViewController {
    func startTimer() {
        updateTimeCounter()
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimeCounter), userInfo: nil, repeats: true)
        }
    }
    
    func endTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = nil
    }

    @objc func updateTimeCounter() {
        workedHoursCounter = viewModel?.currentEmploymentModel?.employmentInfo.clock?.totalHoursWorked() ?? 0
        breakHoursCounter = viewModel?.currentEmploymentModel?.employmentInfo.clock?.totalBreakTime() ?? 0
    }
    
    func displayActions() {
        guard let actions = viewModel?.availableClockOptions else {return}

        let newHeight: CGFloat = 34.0 // Set the desired button height

        actionStackView.arrangedSubviews.forEach {
            actionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if actions.count == 0 {
            let manualTimeEntryTitle = "manual_time_entry".localized
            let manualTimeBtn = clockAction(title: manualTimeEntryTitle, action: #selector(manualEntryClick(_:)))
            
            manualTimeBtn.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
            
            actionStackView.addArrangedSubview(manualTimeBtn)
        }
        if actions.contains(.startWork) {
            let startWorkBtn = clockAction(title: ClockAction.startWork.title,
                                            bgColor: UIColor(named: "startEndWorkButton"),
                                            action: #selector(startWorkClick(_:)))
            actionStackView.addArrangedSubview(startWorkBtn)

            let manualTimeEntryTitle = "manual_time_entry".localized
            let manualTimeBtn = clockAction(title: manualTimeEntryTitle,
                                            bgColor: UIColor(named: "manualTimeEntryButton"),
                                            action: #selector(manualEntryClick(_:)))
            
            manualTimeBtn.heightAnchor.constraint(equalToConstant: newHeight).isActive = true

            actionStackView.addArrangedSubview(manualTimeBtn)
        }
        if actions.contains(.startBreak) {
            let startBreakBtn = clockAction(title: ClockAction.startBreak.title,
                                            bgColor: UIColor(named: "startEndBreakButton"),
                                            action: #selector(startBreakClick(_:)))
            
            startBreakBtn.heightAnchor.constraint(equalToConstant: newHeight).isActive = true

            actionStackView.addArrangedSubview(startBreakBtn)
        }
        if actions.contains(.endBreak) {
            let endBreakBtn = clockAction(title: ClockAction.endBreak.title,
                                          bgColor: UIColor(named: "startEndBreakButton"),
                                          action: #selector(endBreakClick(_:)))
            
            endBreakBtn.heightAnchor.constraint(equalToConstant: newHeight).isActive = true

            actionStackView.addArrangedSubview(endBreakBtn)
        }
        if actions.contains(.endWork) {
            let endWorkBtn = clockAction(title: ClockAction.endWork.title,
                                         bgColor: UIColor(named: "startEndWorkButton"),
                                         action: #selector(endWorkClick(_:)))
            
            endWorkBtn.heightAnchor.constraint(equalToConstant: newHeight).isActive = true

            actionStackView.addArrangedSubview(endWorkBtn)
        }
        if actions.contains(.discardEntry) {
            let discardEntryBtn = clockAction(title: ClockAction.discardEntry.title,
                                              bgColor: UIColor.white,
                                              action: #selector(discardEntryClick(_:)))

            discardEntryBtn.layer.borderWidth = 1.0
            discardEntryBtn.layer.borderColor = UIColor.red.cgColor

            discardEntryBtn.setTitleColor(UIColor.red, for: .normal)
            discardEntryBtn.setTitleColor(UIColor.white, for: .highlighted)
            
            discardEntryBtn.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
            
            actionStackView.addArrangedSubview(discardEntryBtn)
        }
        
        for action in actionStackView.arrangedSubviews {
            let heightConstraint = action.heightAnchor.constraint(equalToConstant: newHeight)
            heightConstraint.isActive = true
        }
    }
    
    fileprivate func clockAction(title: String, bgColor: UIColor? = nil, action: Selector) -> ActionButton {
        let actionBtn = ActionButton(type: .custom)
        actionBtn.setTitle(title, for: .normal)
        actionBtn.addTarget(self, action: action, for: .touchUpInside)
      //  actionBtn.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        if let bgColor = bgColor {
            actionBtn.backgroundColor = bgColor
        }
        
        return actionBtn
    }
    
}

extension TimeCardViewController: EnterTimeViewControllerDelegate {
    func didEnterTime(enterTimeModel: EnterTimeViewModel?) {
        displayClock()
    }
    
    func didCancelEnterTime() {
        
    }
}
