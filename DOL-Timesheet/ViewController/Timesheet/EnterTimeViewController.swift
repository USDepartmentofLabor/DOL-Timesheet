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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var paymentTypeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterTimeView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var startTitleLabel: UILabel!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var breakTimeTitleLabel: UILabel!
    
    @IBOutlet weak var breakTimeInfoButton: InfoButton!
    @IBOutlet weak var hourlyRateTitleLabel: UILabel!
    @IBOutlet weak var commentsTitleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: TimesheetViewControllerDelegate?
    
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
        title = viewModel?.title
        
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableView.automaticDimension

        enterTimeView.addBorder()
        commentTextView.addBorder()
        paymentTypeLabel.scaleFont(forDataType: .enterTimePaymentType)
        titleLabel.scaleFont(forDataType: .enterTimeTitle)
        commentsTitleLabel.scaleFont(forDataType: .enterTimeTitle)
        editBtn.titleLabel?.scaleFont(forDataType: .actionButton)
        scrollView.keyboardDismissMode = .onDrag

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
        
        breakTimeInfoButton.infoType = .breakTime
        breakTimeInfoButton.delegate = self
        
        if viewModel?.paymentType == PaymentType.salary {
            setupSalaryView()
        }
    }
    
    func setupSalaryView() {
        hourlyRateTitleLabel.removeFromSuperview()
    }
    
    func setupAccessibility() {
        commentTextView.accessibilityHint = NSLocalizedString("enter_daily_comments", comment: "Enter Daily Comments")
    }
    
    func displayInfo() {
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
        dismiss(animated: true, completion: nil)
    }

    @objc func save(_ sender: Any?) {
        viewModel?.comment = commentTextView.text
        
        if let errorStr = viewModel?.validate() {
            displayError(message: errorStr, title: "Error")
            return
        }
        
        viewModel?.save()
        delegate?.didEnterTime()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addRowClick(_ sender: Any) {
        _ = viewModel?.addTimeLog()
        displayTime()
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
                displayTime()
            }
        }
    }
    
    func deleteTimeLog(timeLog: TimeLog) {
        viewModel?.removeTimeLog(timeLog: timeLog)
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
        guard let viewModel = viewModel else {
            return false
        }
        
        let errorStr = viewModel.isValid(time: endTime, for: timeLog)
        if !errorStr.isEmpty {
            displayError(message: errorStr)
            return false
        }
        
        return true
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
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
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
