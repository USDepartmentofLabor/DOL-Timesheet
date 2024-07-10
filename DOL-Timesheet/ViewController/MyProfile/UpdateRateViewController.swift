//
//  UpdateRateViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class UpdateRateViewController: UIViewController {
    
    @IBOutlet weak var rateNameTitleLabel: UILabel!
    @IBOutlet weak var rateNameTextField: UITextField!
    @IBOutlet weak var rateNameView: UIView!
    
    @IBOutlet weak var payTitleLabel: UILabel!
    @IBOutlet weak var payTitleTextField: UITextField!
    
    @IBOutlet weak var frequencyTitleLabel: UILabel!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var frequencyPicker: UIPickerView!
    @IBOutlet weak var frequencyPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var frequencyView: UIView!
    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var helpLabel: UILabel!
    
    @IBOutlet weak var discardButton: UIButton!
    
    var employmentModel: EmploymentModel?
    var hourlyRate: HourlyRate?
    
    var payPeriodArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        self.navigationController?.navigationBar.tintColor = .linkColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rateNameView.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
        frequencyView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
        helpView.layer.cornerRadius = 10.0
    }
    
    func setupView() {
        title = "new_rate".localized
        
        rateNameTitleLabel.text = "rate_name".localized
        payTitleLabel.text = "pay".localized
        frequencyTitleLabel.text = "frequency".localized
        
        payPeriodArray = ["payment_type_hourly".localized,
                          "salary_weekly".localized,
                          "salary_monthly".localized,
                          "salary_annually".localized]
        
        helpLabel.text = "help".localized
        
        rateNameTextField.text = ""
        payTitleTextField.text = ""
        frequencyTextField.text = ""
        
        frequencyPickerHeightConstraint.constant = 0
        
        discardButton.layer.borderWidth = 1.0
        discardButton.layer.cornerRadius = 5.0
        discardButton.layer.borderColor = UIColor.red.cgColor

        discardButton.setTitleColor(UIColor.red, for: .normal)
        discardButton.setTitleColor(UIColor.white, for: .highlighted)
        discardButton.setTitle("discard".localized, for: .normal)
        
        discardButton.isHidden = true
    }
    
    func setupData() {
        guard let safeEmploymentModel = employmentModel else { return }
        
        if safeEmploymentModel.paymentType == .hourly {
            guard let safeRate = hourlyRate else { return }

            title = safeRate.name
            rateNameTextField.text = safeRate.name
            payTitleTextField.text = String(safeRate.value)
            frequencyTextField.text = "payment_type_hourly".localized
            return
        }
        
        title = safeEmploymentModel.salary.salaryType.title.localized
        
        rateNameTextField.text = safeEmploymentModel.salary.salaryType.title.localized
        payTitleTextField.text = NumberFormatter.localisedCurrencyStr(from: safeEmploymentModel.salary.amount)
        frequencyTextField.text = safeEmploymentModel.salary.salaryType.title.localized
        let salaryType = safeEmploymentModel.salary.salaryType.title.localized
        
        frequencyPicker.selectRow(1, inComponent: 0, animated: false)
        
        if salaryType == "salary_monthly".localized {
            frequencyPicker.selectRow(2, inComponent: 0, animated: false)

        }
        if salaryType == "salary_annually".localized {
            frequencyPicker.selectRow(3, inComponent: 0, animated: false)

        }
        
        discardButton.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "updateRateHelpScreen",
            let helpVC = segue.destination as? HelpTableViewController {
            helpVC.helpItems = [
                HelpItem(
                    title: "info_break_time_title".localized,
                    body: "info_break_time".localized),
                HelpItem(title: "overnight_hours".localized, body: "info_end_time".localized)]
        }
    }
    
    @IBAction func discardPressed(_ sender: Any) {
        var title = "delete_hourly_rate".localized
        var message = "delete_hourly_rate_warning".localized
        if employmentModel?.paymentType != .hourly {
            title = "delete_salary".localized
            message = "delete_salary_warning".localized
        }
        
        let alertController =
        UIAlertController(title: title,
                          message: message,
                          preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "delete".localized, style: .destructive) { _ in
            }
        )
        present(alertController, animated: true)
    }
}

extension UpdateRateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == frequencyTextField {
            if frequencyPickerHeightConstraint.constant > 1 {
                frequencyPickerHeightConstraint.constant = 0
            } else {
                if frequencyTextField.text?.count == 0 {
                    frequencyTextField.text? = "payment_hour".localized
                }
                frequencyPickerHeightConstraint.constant = 216
            }
            return false
        } else if textField == payTitleTextField {
            if employmentModel?.paymentType == .salary {
                return false
            }
        }
        
        frequencyPickerHeightConstraint.constant = 0
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}

extension UpdateRateViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        frequencyTextField.text = payPeriodArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return payPeriodArray[row]
    }
}

extension UpdateRateViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return payPeriodArray.count
    }
}
