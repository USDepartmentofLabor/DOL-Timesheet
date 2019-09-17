//
//  EnnterTimeViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class EnterTimeViewController: UIViewController {

    var viewModel: EnterTimeViewModel?
    var timeSheetModel: TimesheetViewModel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var paymentTypeLabel: UILabel!
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateDropDownView: DropDownView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterTimeView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var startTitleLabel: UILabel!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var breakTimeTitleLabel: UILabel!
    
    
    @IBOutlet weak var endTimeInfoBtn: InfoButton!
    @IBOutlet weak var breakTimeInfoButton: InfoButton!
    @IBOutlet weak var hourlyRateTitleLabel: UILabel!
    @IBOutlet weak var commentsTitleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: EnterTimeViewControllerDelegate?
    
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupView() {
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        navigationItem.leftBarButtonItem = cancelBtn

        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
        navigationItem.rightBarButtonItem = saveBtn
//        title = viewModel?.title
        title = NSLocalizedString("manual_time_entry", comment: "Time Entry")
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension

        enterTimeView.addBorder()
        commentTextView.addBorder()
        paymentTypeLabel.scaleFont(forDataType: .enterTimePaymentType)
        dateTitleLabel.scaleFont(forDataType: .enterTimeTitle)
        titleLabel.scaleFont(forDataType: .enterTimeTitle)
        commentsTitleLabel.scaleFont(forDataType: .enterTimeTitle)
        editBtn.titleLabel?.scaleFont(forDataType: .actionButton)
        scrollView.keyboardDismissMode = .onDrag

        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(dateBtnClick(_:)))
        dateTapGesture.cancelsTouchesInView = false
        dateDropDownView.addGestureRecognizer(dateTapGesture)

        commentTextView.delegate = self
        
        setupTimeView()
        setupAccessibility()
    }
    
    func setupTimeView() {
        paymentTypeLabel.accessibilityTraits = .header
        titleLabel.accessibilityTraits = .header
        startTitleLabel.scaleFont(forDataType: .columnHeader)
        endTitleLabel.scaleFont(forDataType: .columnHeader)
        breakTimeTitleLabel.scaleFont(forDataType: .columnHeader)
        hourlyRateTitleLabel.scaleFont(forDataType: .columnHeader)
        commentTextView.scaleFont(forDataType: .enterCommentsValue)
        
        endTimeInfoBtn.infoType = .endTime
        endTimeInfoBtn.delegate = self
        
        breakTimeInfoButton.infoType = .breakTime
        breakTimeInfoButton.delegate = self
        
        if viewModel?.paymentType == PaymentType.salary {
            setupSalaryView()
        }
    }
    
    @objc func dateBtnClick(_ sender: Any) {
        let datePickerVC = TimePickerViewController.instantiateFromStoryboard()
        datePickerVC.delegate = self
        datePickerVC.sourceView = (dateDropDownView)
        datePickerVC.pickerMode = .date

        showPopup(popupController: datePickerVC, sender: dateDropDownView)
    }
    
    func setupSalaryView() {
        hourlyRateTitleLabel.removeFromSuperview()
    }
    
    func setupAccessibility() {
        commentTextView.accessibilityHint = NSLocalizedString("enter_daily_comments", comment: "Enter Daily Comments")
    }
    
    func displayInfo() {
        dateDropDownView.title = viewModel?.title ?? ""
        paymentTypeLabel.text = viewModel?.paymentType?.title
        commentTextView.text = viewModel?.comment
        displayTime()
    }
    
    func displayTime() {
        tableView.reloadData()
        
        UIView.animate(withDuration: 0, animations: {
            self.tableView.layoutIfNeeded()
        }) { (complete) in
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
        }
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
        let annnouncementMsg = NSLocalizedString("save_time_entry", comment: "Saved time for")
        let announcementStr = String(format: annnouncementMsg, viewModel?.title ?? "")
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)
        

        delegate?.didEnterTime(enterTimeModel: viewModel)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addRowClick(_ sender: Any) {
        _ = viewModel?.addTimeLog()
//        displayTime()
//        return
        
        guard let viewModel = viewModel, let totalLogs = viewModel.numberOfTimeLogs else {return}
        
        let newIndexPath = IndexPath(row: totalLogs-1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .none)
        
        UIView.animate(withDuration: 0, animations: {
            self.tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: false)
        }) { (complete) in
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
            if let cell = self.tableView.cellForRow(at: newIndexPath) as? EnterHourlyTimeTableViewCell {
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
            }
        }
    }
    
    @IBAction func editClick(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        editTime(edit: tableView.isEditing)
    }
    
    func editTime(edit: Bool) {
        if edit {
            editBtn.setTitle(NSLocalizedString("done", comment: "Done"), for: .normal)
        }
        else {
            editBtn.setTitle(NSLocalizedString("edit", comment: "Edit"), for: .normal)
        }
    }    
}

extension EnterTimeViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 15, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        keyboardHeight = contentInsets.bottom
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

extension EnterTimeViewController: UITableViewDataSource {
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
        cell.delegate = self
        cell.textViewDelegate = self
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
        let titleMsg = NSLocalizedString("delete_time_log", comment: "Delete Time Log")
        
        let errorStr: String
        if let startTimeStr = timeLog.startTime?.formattedTime {
            let errorMsg = NSLocalizedString("delete_confirm_time_log_with_startdate", comment: "Are you sure you want to delete?")
            errorStr = String(format: errorMsg, startTimeStr)
        }
        else {
            errorStr = NSLocalizedString("delete_confirm_time_log", comment: "Are you sure you want to delete?")
        }
        
        let alertController = UIAlertController(title: titleMsg,
                                                message: errorStr,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel))
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: .destructive) { _ in
                self.viewModel?.removeTimeLog(timeLog: timeLog)
                self.displayTime()
        })
        present(alertController, animated: true)
    }

}

extension EnterTimeViewController: EnterTimeTableCellProtocol {
    func remove(cell: UITableViewCell, timeLog: TimeLog) {
        viewModel?.removeTimeLog(timeLog: timeLog)
        displayTime()
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
        let message = NSLocalizedString("warning_split_time", comment: "Time will be entered for next day")
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "Yes"), style: .default, handler: { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel?.splitTime(endTime: endTime, for: timeLog)
            strongSelf.tableView.reloadData()
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("no", comment: "No"), style: .cancel, handler: nil))
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
    
    func contentDidChange(cell: EnterHourlyTimeTableViewCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    func showAlert(cell: UITableViewCell, sender: Any?, alertController: UIAlertController) {
        present(alertController, animated: false)
    }

}


extension EnterTimeViewController {
    public override func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        super.popoverPresentationControllerDidDismissPopover(popoverPresentationController)
        if let timePicketVC = popoverPresentationController.presentedViewController as? TimePickerViewController {
                timePicketVC.delegate?.timeChanged(sourceView: timePicketVC.sourceView, datePicker: timePicketVC.datePicker)
        }
    }
}

extension EnterTimeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let aRect = textView.convert(textView.frame, to: scrollView)
        scrollView.scrollRectToVisible(aRect, animated: true)
    }
}


extension EnterTimeViewController: TimePickerProtocol {
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        viewModel = timeSheetModel?.createEnterTimeViewModel(for: datePicker.date)
        displayInfo()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: dateDropDownView)
    }
}

