//
//  EnterTimeSoftenViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class EnterTimeSoftenViewController: UIViewController {

    var viewModel: EnterTimeViewModel?
    var timeSheetModel: TimesheetViewModel?
    
    @IBOutlet weak var commentsHint: UILabel!
    @IBOutlet weak var employmentView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var helpView: UIView!
    
    @IBOutlet weak var startTimeErrorMessage: UILabel!
    @IBOutlet weak var breakTimeErrorMessage: UILabel!
    @IBOutlet weak var endTimeErrorMessage: UILabel!
    
    @IBOutlet weak var dateDropDownView: DropDownView!
    
    @IBOutlet weak var startDropDownView: DropDownView!
    @IBOutlet weak var breakDropDownView: DropDownView!
    @IBOutlet weak var endDropDownView: DropDownView!
    
    @IBOutlet weak var hourlyRateTitleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    weak var textViewDelegate: UITextViewDelegate?

    
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var rateTitleLabel: UILabel!
    
    @IBOutlet weak var employmentPopUp: UIButton!
    @IBOutlet weak var ratePopUp: UIButton!
    
    weak var delegate: EnterTimeViewControllerDelegate?
    var timePickerVC: TimePickerViewController?
    
    var rateOptions: [HourlyRate]?
    var startTime: Date?
    var breakTime: TimeInterval = 0.0
    var endTime: Date?
    var comment: String = ""

    var timeLog: TimeLog? {
        didSet {
            displayInfo()
        }
    }

    var currentHourlyRate: HourlyRate? {
        didSet {
            ratePopUp.setTitle(currentHourlyRate?.title ?? "", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupView() {
        let cancelBtn = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancel(_:)))
        navigationItem.leftBarButtonItem = cancelBtn

        let saveBtn = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(save(_:)))
        navigationItem.rightBarButtonItem = saveBtn
//        title = viewModel?.title
        title = "manual_time_entry".localized
        
//        tableView.estimatedRowHeight = 150
//        tableView.rowHeight = UITableView.automaticDimension

//        dateTitleLabel.scaleFont(forDataType: .enterTimeTitle)
//        commentsTitleLabel.scaleFont(forDataType: .enterTimeTitle)

        
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(dateBtnClick(_:)))
        dateTapGesture.cancelsTouchesInView = false
        dateDropDownView.addGestureRecognizer(dateTapGesture)
        
        let startTapGesture = UITapGestureRecognizer(target: self, action: #selector(startBtnClick(_:)))
        startTapGesture.cancelsTouchesInView = false
        startDropDownView.addGestureRecognizer(startTapGesture)
        
        let breakTapGesture = UITapGestureRecognizer(target: self, action: #selector(breakBtnClick(_:)))
        breakTapGesture.cancelsTouchesInView = false
        breakDropDownView.addGestureRecognizer(breakTapGesture)
        
        let endTapGesture = UITapGestureRecognizer(target: self, action: #selector(endBtnClick(_:)))
        endTapGesture.cancelsTouchesInView = false
        endDropDownView.addGestureRecognizer(endTapGesture)
        
//        commentTextView.delegate = self
        
        startTime = timeLog?.startTime
        breakTime = timeLog?.totalBreakTime ?? 0
        endTime = timeLog?.endTime
        comment = timeLog?.comment ?? ""
        
        startTimeErrorMessage.text = ""
        breakTimeErrorMessage.text = ""
        endTimeErrorMessage.text = ""
        
        setupTimeView()
        setupEmploymentPopupButton()
        setupRatePopupButton()
        setupAccessibility()
    }
    
    func setupTimeView() {
//        startTitleLabel.scaleFont(forDataType: .columnHeader)
//        endTitleLabel.scaleFont(forDataType: .columnHeader)
//        breakTimeTitleLabel.scaleFont(forDataType: .columnHeader)
//        hourlyRateTitleLabel.scaleFont(forDataType: .columnHeader)
//        commentTextView.scaleFont(forDataType: .enterCommentsValue)
        
        employmentView.layer.cornerRadius = 10
        dateView.layer.cornerRadius = 10
        timeView.layer.cornerRadius = 10
        commentView.layer.cornerRadius = 10
        helpView.layer.cornerRadius = 10
        
        dateDropDownView.title = "date".localized
        startDropDownView.title = "start_time".localized
        breakDropDownView.title = "break_time".localized
        endDropDownView.title = "end_time".localized
    }
    
    func setupEmploymentPopupButton(){
        let optionClosure = {(action : UIAction) in
            print(action.title)
        }
        
        var menuActions: [UIAction] = []
        
        guard let userProfileModel = timeSheetModel?.userProfileModel else { return }
        
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
                
        employmentPopUp.menu = UIMenu(children : menuActions)
        employmentPopUp.showsMenuAsPrimaryAction = true
        
        employmentPopUp.changesSelectionAsPrimaryAction = true
    }
    
    func setCurrentUser(user: User) {
        timeSheetModel?.setCurrentEmploymentModel(for: user)
        setupRatePopupButton()
    }
    
    func setupRatePopupButton(){
        rateOptions = timeSheetModel?.currentEmploymentModel?.hourlyRates
        
        let optionClosure = {(action : UIAction) in
            print(action.title)
        }
        
        var menuActions: [UIAction] = []

        guard  let options = rateOptions else {
            return
        }
                
        for option in options {
            let action = UIAction(title: option.title, handler: {_ in
                self.currentHourlyRate = option
            })
            menuActions.append(action)
        }
        
        ratePopUp.menu = UIMenu(children : menuActions)
        ratePopUp.showsMenuAsPrimaryAction = true
        ratePopUp.changesSelectionAsPrimaryAction = true
    }
    
    @objc func dateBtnClick(_ sender: Any) {
        let datePickerVC = TimePickerViewController.instantiateFromStoryboard()
        datePickerVC.delegate = self
        datePickerVC.sourceView = (dateDropDownView)
        datePickerVC.pickerMode = .date

        showPopup(popupController: datePickerVC, sender: dateDropDownView)
        self.timePickerVC = datePickerVC
    }
    
    @objc func startBtnClick(_ sender: Any) {
        showPicker(mode: .time, sender: startDropDownView as Any, date: startTime)
    }
    
    @objc func breakBtnClick(_ sender: Any) {
        showPicker(mode: .countDownTimer, sender: breakDropDownView as Any, countdownDuration: breakTime)
    }
    
    @objc func endBtnClick(_ sender: Any) {
        showPicker(mode: .time, sender: endDropDownView as Any, date: endTime)
    }
    
    func showPicker(mode: UIDatePicker.Mode, sender: Any, date: Date? = nil, countdownDuration: TimeInterval = 0) {
        let timePickerVC = TimePickerViewController.instantiateFromStoryboard()
        timePickerVC.delegate = self
        timePickerVC.sourceView = (sender as! UIView)
        timePickerVC.pickerMode = mode
        if mode == .countDownTimer {
            timePickerVC.countdownDuration = countdownDuration
        }
        else if mode == .time {
            if let date = date {
                timePickerVC.currentDate = date
            }
            else if let logDate = timeLog?.dateLog?.date {
                var dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: logDate)
                let timeComponent = Calendar.current.dateComponents([.hour, .minute], from: Date())
                dateComponent.hour = timeComponent.hour
                dateComponent.minute = timeComponent.minute
                timePickerVC.currentDate = Calendar.current.date(from: dateComponent)
            }
        }
        showPopup(popupController: timePickerVC, sender: sender as! UIView)
        self.timePickerVC = timePickerVC
    }
    
    func setupAccessibility() {
        commentTextView.accessibilityHint = "enter_daily_comments".localized
    }
    
    func displayInfo() {
        dateDropDownView.value = viewModel?.title ?? ""
        
        let formattedStartTime = startTime?.formattedTime
        startDropDownView.value = formattedStartTime ?? ""
        
        let formattedEndTime = endTime?.formattedTime
        endDropDownView.value = formattedEndTime ?? ""
        
        displayBreakTime(timeInSeconds: breakTime)
    }

    @objc func cancel(_ sender: Any?) {
        delegate?.didCancelEnterTime()
        dismiss(animated: true, completion: nil)
    }

    @objc func save(_ sender: Any?) {
        guard let safeViewModel = viewModel else { return }
        if startTime == nil || endTime == nil {
            return
        }
        
        if timeLog == nil {
            if let safeTimeLogs = safeViewModel.timeLogs,
                safeTimeLogs.count > 0 {
                
                timeLog = safeTimeLogs[safeTimeLogs.count - 1]
            }else {
                timeLog = safeViewModel.addTimeLog()
            }
        }
        
        timeLog?.startTime = startTime
        timeLog?.addBreak(duration: breakTime)
        timeLog?.endTime = endTime
        
        if !isValid(endTime: endTime!, for: timeLog) {
            return
        }
        
        timeLog?.comment = comment
                
        if let errorStr = viewModel?.validate() {
            displayError(message: errorStr, title: "Error")
            return
        }
        
        safeViewModel.save()
        let annnouncementMsg = "save_time_entry".localized
        let announcementStr = String(format: annnouncementMsg, viewModel?.title ?? "")
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)
        

        delegate?.didEnterTime(enterTimeModel: viewModel)
        dismiss(animated: true, completion: nil)
    }
    
}

extension EnterTimeSoftenViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfTimeLogs ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeLog = viewModel?.timeLogs?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: EnterHourlyTimeTableViewCell.reuseIdentifier) as! EnterHourlyTimeTableViewCell
            
        cell.timeLog = timeLog
//        cell.textViewDelegate = self
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let timeLog = viewModel?.timeLogs?[indexPath.row] {
                deleteTimeLog(timeLog: timeLog)
            }
        }
    }
    
    func deleteTimeLog(timeLog: TimeLog) {
        let titleMsg = "delete_time_log".localized
        
        let errorStr: String
        if let startTimeStr = timeLog.startTime?.formattedTime {
            let errorMsg = "delete_confirm_time_log_with_startdate".localized
            errorStr = String(format: errorMsg, startTimeStr)
        }
        else {
            errorStr = "delete_confirm_time_log".localized
        }
        
        let alertController = UIAlertController(title: titleMsg,
                                                message: errorStr,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "delete".localized, style: .destructive) { _ in
                self.viewModel?.removeTimeLog(timeLog: timeLog)
        })
        present(alertController, animated: true)
    }
    
    func displayBreakTime(timeInSeconds: Double?) {
        guard let timeInSeconds = timeInSeconds else {
            breakDropDownView.value = "0 Min"
            return
        }
        
        let timeStr: String = Date.secondsToHoursMinutes(seconds: timeInSeconds)
        breakDropDownView.value = timeStr
    }

}

extension EnterTimeSoftenViewController {
    func dismissPicker() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isValid(startTime: Date, for timeLog: TimeLog?) -> Bool {
        guard let viewModel = viewModel else {
            startTimeErrorMessage.text = "Internal View Model Error"
            return false
        }
        
        let errorStr = viewModel.isValid(time: startTime, for: timeLog, isStartTime: true)
        if !errorStr.isEmpty {
            startTimeErrorMessage.text = errorStr
            displayError(message: errorStr)
            return false
        }
        
        startTimeErrorMessage.text = ""
        return true
    }
    
    func isValid(endTime: Date, for timeLogTest: TimeLog?) -> Bool {
        // If endTime is before StartTime
        // Warn if this spans over next day?
        //MARK: handel nightShift elsewhere
//        if timeLog.startTime?.compare(endTime) != .orderedAscending {
//            handleNightShift(endTime: endTime, for: timeLog)
//            return false
//        }
        
        return true
    }
    
    func isValid(newEndTime: Date) -> Bool {
        guard let safeStartTime = startTime else {
            endTimeErrorMessage.text = "set_start_time_before_end_time".localized
            alert(message: "set_start_time_before_end_time".localized)
            return false
        }
        
        if safeStartTime.compare(newEndTime) != .orderedAscending {
            //Mark: rethink handleNightShift() logic here
            //if the user somehow work over midnight
            
        }

        if safeStartTime > newEndTime {
            endTimeErrorMessage.text = "err_endtime_is_before_startTime".localized
            displayError(message: "err_endtime_is_before_startTime".localized)
            return false
        }
        
        endTimeErrorMessage.text = ""
        return true
    }
    
    func handleNightShift(endTime: Date, for timeLog: TimeLog) {
        let message = "warning_split_time".localized
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localized, style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel?.splitTime(endTime: endTime, for: timeLog)
        }))
        
        alertController.addAction(UIAlertAction(title: "no".localized, style: .cancel, handler: nil))
        present(alertController, animated: false)
    }
    
    func isValid(breakTime: Double, for timeLog: TimeLog?) -> Bool {
        guard let viewModel = viewModel else {
            return false
        }
        
        let errorStr = viewModel.isValid(breakTime: breakTime, for: timeLog)
        if !errorStr.isEmpty {
            displayError(message: errorStr)
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "newTimeHelpScreen",
            let helpVC = segue.destination as? HelpTableViewController {
            helpVC.helpItems = [
                HelpItem(
                    title: "info_break_time_title".localized,
                    body: "info_break_time".localized),
                HelpItem(title: "overnight_hours".localized, body: "info_end_time".localized)]
        }
    }
}


extension EnterTimeSoftenViewController {
    public override func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        super.popoverPresentationControllerDidDismissPopover(popoverPresentationController)
        if let timePicketVC = popoverPresentationController.presentedViewController as? TimePickerViewController {
                timePicketVC.delegate?.timeChanged(sourceView: timePicketVC.sourceView, datePicker: timePicketVC.datePicker)
        }
    }
}

extension EnterTimeSoftenViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        comment = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        comment = textView.text
    }
    func textViewDidChange(_ textView: UITextView) {
        comment = textView.text
        if comment.count == 0 {
            commentsHint.isHidden = false
        } else {
            commentsHint.isHidden = true
        }
    }
    
}


extension EnterTimeSoftenViewController: TimePickerProtocol {
    func donePressed() {
        guard let pickerVC = self.timePickerVC else { return }
        timeChanged(sourceView: pickerVC.sourceView, datePicker: pickerVC.datePicker)
        self.dismiss(animated: true, completion: nil)
    }
    
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        if sourceView == dateDropDownView {
            viewModel = timeSheetModel?.createEnterTimeViewModel(for: datePicker.date)
            displayInfo()
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: dateDropDownView)
        } else if sourceView == startDropDownView {
            let time = datePicker.date.removeSeconds()
            if isValid(startTime: time, for: timeLog) {
                startTime = time
            }
            if let safeEndTime = endTime {
                if isValid(newEndTime: safeEndTime) {
                    endTimeErrorMessage.text = ""
                }
            }
        } else if sourceView == endDropDownView {
            var time = datePicker.date.removeSeconds()
            
            if time.isMidnight() {
                time = time.addDays(days: 1)
            }
            
            if isValid(newEndTime: time) {
                endTime = time
                endTimeErrorMessage.text = ""
            }
            
        } else if sourceView == breakDropDownView,
                  isValid(breakTime: datePicker.countDownDuration, for: timeLog) {
            updateBreakTime(duration: datePicker.countDownDuration)
        }
        displayInfo()
    }
    
    func alert(message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
        present(alertController, animated: false)
    }

    func updateBreakTime(duration: TimeInterval) {
        if duration <= EmploymentModel.ALLOWED_BREAK_SECONDS {
          //  breakTimeErrorMessage.text = "break_time_warning".localized
            
            let title = "info_break_time_title".localized
            let message = "break_time_warning".localized
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { [weak self] (action) in
                guard let strongSelf = self else {return}
                strongSelf.timeLog?.addBreak(duration: duration)
                strongSelf.displayBreakTime(timeInSeconds: duration)
            }))
            showAlert(sender: breakDropDownView, alertController: alertController)
        }
        else {
            breakTimeErrorMessage.text = ""
            breakTime = duration
        }
    }
    
    func showAlert(sender: Any?, alertController: UIAlertController) {
        present(alertController, animated: false)
    }
}
