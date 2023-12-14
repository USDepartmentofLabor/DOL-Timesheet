//
//  EnnterTimeViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class EnterTimeSoftenViewController: UIViewController {

    var viewModel: EnterTimeViewModel?
    var timeSheetModel: TimesheetViewModel?

    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateDropDownView: DropDownView!
    
    @IBOutlet weak var startTitleLabel: UILabel!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var breakTimeTitleLabel: UILabel!
    
    @IBOutlet weak var hourlyRateTitleLabel: UILabel!
    @IBOutlet weak var commentsTitleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var rateTitleLabel: UILabel!
    
    @IBOutlet weak var employmentPopUp: UIButton!
    @IBOutlet weak var ratePopUp: UIButton!
    
    weak var delegate: EnterTimeViewControllerDelegate?
    var timePickerVC: TimePickerViewController?
    
    var rateOptions: [HourlyRate]?


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

        commentTextView.addBorder()
//        dateTitleLabel.scaleFont(forDataType: .enterTimeTitle)
        dateTitleLabel.text = "date".localized
//        commentsTitleLabel.scaleFont(forDataType: .enterTimeTitle)

        
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(dateBtnClick(_:)))
        dateTapGesture.cancelsTouchesInView = false
        dateDropDownView.addGestureRecognizer(dateTapGesture)

//        commentTextView.delegate = self
        
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
        
        if viewModel?.paymentType == PaymentType.salary {
            setupSalaryView()
        }
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
    
    func setupSalaryView() {
        hourlyRateTitleLabel.removeFromSuperview()
    }
    
    func setupAccessibility() {
        commentTextView.accessibilityHint = "enter_daily_comments".localized
    }
    
    func displayInfo() {
        startTitleLabel.text = "start".localized
        endTitleLabel.text = "end".localized
        breakTimeTitleLabel.text = "break".localized
        if let hourlyLabel = hourlyRateTitleLabel {
            hourlyLabel.text = "rate".localized
        }
        commentsTitleLabel.text = "comments".localized

        dateDropDownView.title = viewModel?.title ?? ""
        commentTextView.text = viewModel?.comment
    }

    @objc func cancel(_ sender: Any?) {
        delegate?.didCancelEnterTime()
        dismiss(animated: true, completion: nil)
    }

    @objc func save(_ sender: Any?) {
        viewModel?.comment = commentTextView.text
                
        if let errorStr = viewModel?.validate() {
            displayError(message: errorStr, title: "Error")
            return
        }
        
        viewModel?.save()
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

}

extension EnterTimeSoftenViewController {
    func dismissPicker() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func remove(cell: UITableViewCell, timeLog: TimeLog) {
        viewModel?.removeTimeLog(timeLog: timeLog)
    }
    
    func showPicker(cell: UITableViewCell, sender: Any?, pickerVC: UIViewController) {
        view.endEditing(true)
        showPopup(popupController: pickerVC, sender: sender as! UIView)
    }
    
    func isValid(startTime: Date, for timeLog: TimeLog?) -> Bool {
        guard let viewModel = viewModel else {
            return false
        }
        
        let errorStr = viewModel.isValid(time: startTime, for: timeLog, isStartTime: true)
        if !errorStr.isEmpty {
            displayError(message: errorStr)
            return false
        }
        
        return true
    }
    
    func isValid(endTime: Date, for timeLog: TimeLog?) -> Bool {
        guard let viewModel = viewModel, let timeLog = timeLog else {
            return false
        }
        
        if timeLog.startTime == nil {
            let message = "set_start_time_before_end_time".localized
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "ok".localized, style: .cancel, handler: nil))
            present(alertController, animated: false)
            return false
        }

        // If endTime is before StartTime
        // Warn if this spans over next day?
        if timeLog.startTime?.compare(endTime) != .orderedAscending {
            handleNightShift(endTime: endTime, for: timeLog)
            return false
        }
        
        let errorStr = viewModel.isValid(time: endTime, for: timeLog)
        if !errorStr.isEmpty {
            displayError(message: errorStr)
            return false
        }
        
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
    
    
    func showAlert(cell: UITableViewCell, sender: Any?, alertController: UIAlertController) {
        present(alertController, animated: false)
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


extension EnterTimeSoftenViewController: TimePickerProtocol {
    func donePressed() {
        guard let pickerVC = self.timePickerVC else { return }
        timeChanged(sourceView: pickerVC.sourceView, datePicker: pickerVC.datePicker)
        self.dismiss(animated: true, completion: nil)
    }
    
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        viewModel = timeSheetModel?.createEnterTimeViewModel(for: datePicker.date)
        displayInfo()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: dateDropDownView)
    }
}

