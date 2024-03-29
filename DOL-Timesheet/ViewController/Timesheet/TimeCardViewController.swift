//
//  TimeCardViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/3/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class TimeCardViewController: UIViewController, TimeViewDelegate, TimeViewControllerDelegate {
    func didUpdateUser() {
    
    }
    
    func didUpdateEmploymentInfo() {
    
    }
    
    func didUpdateLanguageChoice() {
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    
    @IBOutlet weak var rateDropDownView: DropDownView!
    
    @IBOutlet weak var rateViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var hoursWorkedTitleLabel: UILabel!
    @IBOutlet weak var workedHoursView: UIView!
    @IBOutlet weak var workedHoursCounterLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!

    @IBOutlet weak var hoursWorkedInfoBtn: UIButton!
    
    @IBOutlet weak var breakHoursTitleLabel: UILabel!
    @IBOutlet weak var breakHoursView: UIView!
    @IBOutlet weak var breakHoursCounterLabel: UILabel!
    @IBOutlet weak var breakTimeInfoLabel: UILabel!
    @IBOutlet weak var breakTimeInfoBtn: UIButton!
    
    @IBOutlet weak var actionStackView: UIStackView!
    
    @IBOutlet weak var commentsTitleLabel: UILabel!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTextView: UITextView!
    
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
    var timer: Timer?
    var currentHourlyRate: HourlyRate? {
        didSet {
            rateDropDownView.title = currentHourlyRate?.title ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Localizer.initialize()  
        setupNavigationBarSettings()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Localizer.initialize()
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
        
        rateDropDownView.titleLabel.scaleFont(forDataType: .timesheetSelectedUser)
        rateDropDownView.titleLabel.textColor = UIColor(named: "darkTextColor")

        workedHoursCounterLabel.scaleFont(forDataType: .timeCounterText)
        hoursWorkedTitleLabel.scaleFont(forDataType: .nameValueTitle)
        timeInfoLabel.scaleFont(forDataType: .timecardInfoText)
        timeInfoLabel.textColor = UIColor(named: "appSecondaryColor")

        breakHoursCounterLabel.scaleFont(forDataType: .breakTimeCounterText)
        breakHoursTitleLabel.scaleFont(forDataType: .nameValueText)
        breakTimeInfoLabel.scaleFont(forDataType: .timecardInfoText)
        breakTimeInfoLabel.textColor = UIColor(named: "appSecondaryColor")
        
        commentsTitleLabel.scaleFont(forDataType: .enterTimeTitle)
        commentsTextView.addBorder()
        
        workedHoursView.addBorder()
        breakHoursView.addBorder()
    }
    
    func displayInfo() {
        // Remove Rate if salaried employee
        
        hoursWorkedTitleLabel.text = "hours_worked".localized
        breakHoursTitleLabel.text = "break_hours".localized
        
        if let paymentType = viewModel?.currentEmploymentModel?.paymentType,
            paymentType == .salary {
            rateDropDownView.isHidden = true
            rateDropDownView.isAccessibilityElement = false
            rateViewBottomConstraint.priority = .init(200)
            rateViewHeightConstraint.priority = .init(200)
        }
        else {
            rateDropDownView.isHidden = false
            rateDropDownView.isAccessibilityElement = true
            rateViewBottomConstraint.priority = .init(900)
            rateViewHeightConstraint.priority = .init(900)
            
            let rateTapGesture = UITapGestureRecognizer(target: self, action: #selector(rateClick(_:)))
            rateTapGesture.cancelsTouchesInView = false
            rateDropDownView.addGestureRecognizer(rateTapGesture)
        }
        
        if let hourlyRates = viewModel?.currentEmploymentModel?.hourlyRates, hourlyRates.count > 0 {
            currentHourlyRate = hourlyRates[0]
        }
        else {
            currentHourlyRate = nil
        }
        displayClock()
    }
    
    func displayClock() {
        let clockState = viewModel?.clockState
        if clockState == .clockedIn || clockState == .inBreak {
            startTimer()
            // display Comments
            commentsView.isHidden = false
            rateDropDownView.isEnabled = false
            if let hourlyRate = viewModel?.currentEmploymentModel?.employmentInfo.clock?.hourlyRate {
                currentHourlyRate = hourlyRate
            }
        }
        else {
            // hide Comments
            commentsView.isHidden = true
            timeInfoLabel.text = ""
            breakTimeInfoLabel.text = ""
            rateDropDownView.isEnabled = true
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
            if hourlyRate.value < 0.1 {
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
        
        viewModel?.clock(action: .startWork, hourlyRate: currentHourlyRate, comments: nil)
        displayClock()
    }
    
    @IBAction func endWorkClick(_ sender: Any) {
        
        
        if !isValidHourlyRate(){
            self.discardEntry()
            return
        }
        
        if ( viewModel?.currentEmploymentModel?.employmentInfo.clock?.totalHoursWorked() ?? 0 >= 0) {
            viewModel?.clock(action: .endWork, comments: commentsTextView.text)
            
            if let clock = viewModel?.currentEmploymentModel?.employmentInfo.clock {
                
                if !(clock.startTime?.isEqualOnlyDate(date: Date()) ?? true) {
                    let message = "warning_split_time".localized
                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "yes".localized, style: .default, handler: { [weak self] (action) in
                        guard let strongSelf = self else { return }
                            strongSelf.performSegue(withIdentifier: "enterTime", sender: clock)
                    }))
                        
                    alertController.addAction(UIAlertAction(title: "no".localized, style: .cancel, handler: nil))
                    present(alertController, animated: false)
                }
                else {
                    performSegue(withIdentifier: "enterTime", sender: clock)
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
        if isValidHourlyRate() {
            viewModel?.clock(action: .startBreak, comments: commentsTextView.text)
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
        if ( viewModel?.currentEmploymentModel?.employmentInfo.clock?.totalBreakTime() ?? 0 >= 0) {
            viewModel?.clock(action: .endBreak, comments: commentsTextView.text)
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
        viewModel?.clock(action: .discardEntry, comments: nil)
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
            commentsTextView.text = clock.comments
        }
        else {
            timeInfoLabel.text = ""
        }
        commentsTitleLabel.text = "comments".localized
        updateTimeCounter()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterTime",
            let navVC = segue.destination as? UINavigationController,
            let enterTimeVC = navVC.topViewController as? EnterTimeViewController,
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
        }
        else if segue.identifier == "showUserProfile",
             let navVC = segue.destination as? UINavigationController,
             let profileVC = navVC.topViewController as? SetupProfileViewController,
             let viewModel = viewModel {
             profileVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
             profileVC.delegate = self
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

        actionStackView.arrangedSubviews.forEach {
            actionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        if actions.count == 0 {
            let manualTimeEntryTitle = "manual_time_entry".localized
            let manualTimeBtn = clockAction(title: manualTimeEntryTitle, action: #selector(manualEntryClick(_:)))
            actionStackView.addArrangedSubview(manualTimeBtn)
        }
        if actions.contains(.startWork) {
            let startWorkBtn = clockAction(title: ClockAction.startWork.title,
                                            bgColor: UIColor(named: "navButtonColor"),
                                            action: #selector(startWorkClick(_:)))
            actionStackView.addArrangedSubview(startWorkBtn)

            let manualTimeEntryTitle = "manual_time_entry".localized
            let manualTimeBtn = clockAction(title: manualTimeEntryTitle, action: #selector(manualEntryClick(_:)))
            actionStackView.addArrangedSubview(manualTimeBtn)
        }
        if actions.contains(.startBreak) {
            let startBreakBtn = clockAction(title: ClockAction.startBreak.title,
                                            bgColor: #colorLiteral(red: 0.8274509804, green: 0.5960784314, blue: 0.2196078431, alpha: 1),
                                            action: #selector(startBreakClick(_:)))
            
            actionStackView.addArrangedSubview(startBreakBtn)
        }
        if actions.contains(.endBreak) {
            let endBreakBtn = clockAction(title: ClockAction.endBreak.title,
                                          bgColor: #colorLiteral(red: 0.8274509804, green: 0.5960784314, blue: 0.2196078431, alpha: 1),
                                          action: #selector(endBreakClick(_:)))
            actionStackView.addArrangedSubview(endBreakBtn)
        }
        if actions.contains(.endWork) {
            let endWorkBtn = clockAction(title: ClockAction.endWork.title,
                                         action: #selector(endWorkClick(_:)))
            actionStackView.addArrangedSubview(endWorkBtn)
        }
        if actions.contains(.discardEntry) {
            let discardEntryBtn = clockAction(title: ClockAction.discardEntry.title,
                                              bgColor: UIColor(named: "appSecondaryColor"),
                                              action: #selector(discardEntryClick(_:)))
            actionStackView.addArrangedSubview(discardEntryBtn)
        }
    }
    
    fileprivate func clockAction(title: String, bgColor: UIColor? = nil, action: Selector) -> ActionButton {
        let actionBtn = ActionButton(type: .custom)
        actionBtn.setTitle(title, for: .normal)
        actionBtn.addTarget(self, action: action, for: .touchUpInside)
        actionBtn.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        if let bgColor = bgColor {
            actionBtn.backgroundColor = bgColor
        }
        return actionBtn
    }
    
}

extension TimeCardViewController {
    @objc func rateClick(_ sender: Any) {
        guard rateDropDownView.isEnabled else { return }
        guard  let options =  viewModel?.currentEmploymentModel?.hourlyRates else {
            return
        }

        let optionsVC = OptionsListViewController(options: options,
                                                  title: "")
        optionsVC.didSelect = { [weak self] (popVC: UIViewController, hourlyRate: HourlyRate?) in
            guard let strongSelf = self else { return }
            if let hourlyRate = hourlyRate {
                strongSelf.currentHourlyRate = hourlyRate
            }
            popVC.dismiss(animated: true, completion: nil)
        }

        showPopup(popupController: optionsVC, sender: rateDropDownView)
    }

}

extension TimeCardViewController: EnterTimeViewControllerDelegate {
    func didEnterTime(enterTimeModel: EnterTimeViewModel?) {
        displayClock()
    }
    
    func didCancelEnterTime() {
        
    }
}
