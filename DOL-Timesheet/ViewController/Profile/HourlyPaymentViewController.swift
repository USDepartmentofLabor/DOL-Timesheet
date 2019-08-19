//
//  HourlyPaymentViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/18/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HourlyPaymentViewController: UIViewController {

    var viewModel: EmploymentModel!
    
    @IBOutlet weak var titleLabelInfo: LabelInfoView!
    
    @IBOutlet weak var hourlyContentView: UIView!
    @IBOutlet weak var hourlyTitleLabel: UILabel!
    @IBOutlet weak var hourlyRateTableView: UITableView!
    @IBOutlet weak var hourlyRateTableViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        title = NSLocalizedString("hourly_payment_title", comment: "Hourly Payment Title")
        
        hourlyContentView.addBorder()
        hourlyRateTableView.estimatedRowHeight = 44
        hourlyRateTableView.rowHeight = UITableView.automaticDimension

        hourlyTitleLabel.scaleFont(forDataType: .headingTitle)
        
        if viewModel.isProfileEmployer {
            titleLabelInfo.title = NSLocalizedString("hourly_rate_employer", comment: "Hourly Rate")
            titleLabelInfo.infoType = .employer_hourlyPayRate
        }
        else {
            titleLabelInfo.title = NSLocalizedString("hourly_rate_employee", comment: "Hourly Rate")
            titleLabelInfo.infoType = .employee_hourlyPayRate
        }
        titleLabelInfo.delegate = self
        
        if viewModel?.hourlyRates?.count ?? 0 > 0 {
            loadHourlyRate()
        }
        else {
            addRate()
        }
    }

    @IBAction func addMoreRateClick(_ sender: Any) {
        addRate()
    }
    
    func addRate() {
        viewModel?.newHourlyRate()
//        loadHourlyRate()
        
        guard let viewModel = viewModel, let totalHourlyRates = viewModel.hourlyRates?.count else {return}
        let newIndexPath = IndexPath(row: totalHourlyRates-1, section: 0)
        hourlyRateTableView.insertRows(at: [newIndexPath], with: .none)
        
        UIView.animate(withDuration: 0, animations: {
            self.hourlyRateTableView.scrollToRow(at: newIndexPath, at: .bottom, animated: false)
        }) { (complete) in
            self.hourlyRateTableViewHeightConstraint.constant = self.hourlyRateTableView.contentSize.height
            if let cell = self.hourlyRateTableView.cellForRow(at: newIndexPath) as? HourlyRateTableViewCell {
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
            }
        }
        
        let prevIndexPath = IndexPath(row: newIndexPath.row-1, section: 0)
        if let prevCell = hourlyRateTableView.cellForRow(at: prevIndexPath) as? HourlyRateTableViewCell {
            prevCell.rateValueTextField.returnKeyType = .next
        }
    }

    func loadHourlyRate() {
        hourlyRateTableView.reloadData()
        UIView.animate(withDuration: 0, animations: {
            self.hourlyRateTableView.layoutIfNeeded()
        }) { (complete) in
            self.hourlyRateTableViewHeightConstraint.constant = self.hourlyRateTableView.contentSize.height
        }
    }
}

extension HourlyPaymentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hourlyRates?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HourlyRateTableViewCell.reuseIdentifier) as! HourlyRateTableViewCell
        
        if let hourlyRate = viewModel.hourlyRates?[indexPath.row] {
            cell.hourlyRate = hourlyRate
        }

        cell.rateNameTextField.delegate = self
        cell.rateValueTextField.delegate = self
        cell.itemIndex = indexPath.row
        cell.delegate = self
        
        cell.rateNameTextField.tag = indexPath.row + 1
        cell.rateValueTextField.tag = (indexPath.row+1) * 100
        if indexPath.row < (viewModel.hourlyRates?.count ?? 0) - 1 {
            cell.rateValueTextField.returnKeyType = .next
        }
        else {
            cell.rateValueTextField.returnKeyType = .done
        }
        
        return cell
    }
}

extension HourlyPaymentViewController: HourlyRateCellDelegate {
    func removeItem(index: Int) {
        guard index < viewModel?.hourlyRates?.count ?? 0 else { return }
        guard let hourlyRate = viewModel.hourlyRates?[index] else {return}
        
        let titleMsg = NSLocalizedString("delete_hourly_rate", comment: "Delete Hourly Rate")
        let errorMsg = NSLocalizedString("delete_confirm_hourly_rate_log", comment: "Are you sure you want to delete?")
        let errorStr = String(format: errorMsg, hourlyRate.name ?? "")
    
        let alertController = UIAlertController(title: titleMsg,
                                            message: errorStr,
                                            preferredStyle: .alert)
    
        alertController.addAction(
        UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel))
        alertController.addAction(
        UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: .destructive) { _ in
            self.viewModel.deleteHourlyRate(hourlyRate: hourlyRate)
            
            let deleteAnnouncement = NSLocalizedString("hourly_rate_deleted", comment: "Deleted HourlyRate")
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: deleteAnnouncement)

            self.loadHourlyRate()
        })
        present(alertController, animated: true)
    }
}

extension HourlyPaymentViewController {
    func validateInput() -> String? {
        var errorStr: String? = nil
        
        if (viewModel?.hourlyRates?.count ?? 0) < 1 {
            errorStr = NSLocalizedString("err_add_hourly_rate", comment: "Add Hourly Rate")
        }
        else {
            viewModel?.hourlyRates?.forEach {
                if ($0.name ?? "").isEmpty {
                    errorStr = NSLocalizedString("err_add_hourly_rate_name", comment: "Add Hourly Rate name")
                    return
                }
                else if $0.value <= 0 {
                    errorStr = NSLocalizedString("err_add_hourly_rate_value", comment: "Add Hourly Rate value")
                    return
                }
            }
        }
        
        return errorStr
    }
}

extension HourlyPaymentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        return true
    }
}

extension HourlyPaymentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        else if textField.returnKeyType == .next {
            let nextTag: Int
            if textField.tag < 100 {
                nextTag = textField.tag * 100
            }
            else {
                nextTag = (textField.tag / 100) + 1
            }
            if let nextView = view.viewWithTag(nextTag) {
                nextView.becomeFirstResponder()
            }
        }
        return true
    }
}
