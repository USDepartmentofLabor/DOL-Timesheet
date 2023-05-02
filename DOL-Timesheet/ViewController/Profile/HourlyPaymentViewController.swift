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
    @IBOutlet weak var addRateBtn: SubActionButton!
    @IBOutlet weak var fslaTextView: UITextView!
    var paymentViewDelegate: SetupPaymentViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hourlyRateTableViewHeightConstraint.constant = hourlyRateTableView.contentSize.height
    }
    
    func setupView() {
        
        hourlyContentView.addBorder()
        hourlyRateTableView.estimatedRowHeight = 44
        hourlyRateTableView.rowHeight = UITableView.automaticDimension
        
        if viewModel.isProfileEmployer {
            titleLabelInfo.title = "hourly_rate_employer".localized
            titleLabelInfo.infoType = .employer_hourlyPayRate
        }
        else {
            titleLabelInfo.title = "hourly_rate_employee".localized
            titleLabelInfo.infoType = .employee_hourlyPayRate
        }
        titleLabelInfo.delegate = self
        
        if viewModel?.hourlyRates?.count ?? 0 > 0 {
            loadHourlyRate()
        }
        else {
            addRate()
        }
        fslaTextView.text = "fsla_requirements".localized
        addRateBtn.setTitle("add_another_rate".localized, for: .normal)
        
        let attributedString = NSMutableAttributedString(string:fslaTextView.text)
        if #available(iOS 13.0, *) {
            attributedString.addAttributes(
                [NSAttributedString.Key.font: Style.scaledFont(forDataType: .aboutText),
                 NSAttributedString.Key.foregroundColor: UIColor.linkColor],
                range: NSRange(location: 0, length: attributedString.length))
        } else {
            attributedString.addAttribute(.font, value: Style.scaledFont(forDataType: .aboutText), range: NSRange(location: 0, length: attributedString.length))
        }
        attributedString.addAttribute(.link, value: "fsla", range: NSRange(location: 0, length: attributedString.length))
        fslaTextView.attributedText = attributedString
        fslaTextView.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.linkColor
        ]
        fslaTextView.delegate = self
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
        cell.perHourLabel.tag = cell.rateValueTextField.tag + 1
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
        
        let titleMsg = "delete_hourly_rate".localized
        let errorMsg = "delete_confirm_hourly_rate_log".localized
        let errorStr = String(format: errorMsg, hourlyRate.name ?? "")
    
        let alertController = UIAlertController(title: titleMsg,
                                            message: errorStr,
                                            preferredStyle: .alert)
    
        alertController.addAction(
        UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
        UIAlertAction(title: "delete".localized, style: .destructive) { _ in
            self.viewModel.deleteHourlyRate(hourlyRate: hourlyRate)
            
            let deleteAnnouncement = "hourly_rate_deleted".localized
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: deleteAnnouncement)

            self.loadHourlyRate()
            UIAccessibility.post(notification:  UIAccessibility.Notification.layoutChanged, argument: self.addRateBtn)
        })
        present(alertController, animated: true)
    }
}

extension HourlyPaymentViewController {
    func validateInput() -> String? {
        var errorStr: String? = nil
        
        if (viewModel?.hourlyRates?.count ?? 0) < 1 {
            errorStr = "err_add_hourly_rate".localized
        }
        else {
            viewModel?.hourlyRates?.forEach {
                if ($0.name ?? "").isEmpty {
                    errorStr = "err_add_hourly_rate_name".localized
                    return
                }
                else if $0.value <= 0 {
                    errorStr = "err_add_hourly_rate_value".localized
                    return
                }
            }
        }
        
        return errorStr
    }
}

extension HourlyPaymentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        paymentViewDelegate?.displayFSLARule()
        return false
    }
}

extension HourlyPaymentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
            let perHourTag = textField.tag + 1
            if let view = view.viewWithTag(perHourTag) {
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: view)
            }
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


