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
    
    @IBOutlet weak var payTitleLabel: UILabel!
    @IBOutlet weak var payTitleTextField: UITextField!
    
    @IBOutlet weak var frequencyTitleLabel: UILabel!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var frequencyPicker: UIPickerView!
    @IBOutlet weak var frequencyPickerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var helpLabel: UILabel!
    
    var employmentModel: EmploymentModel?
    var hourlyRate: HourlyRate?
    
    var payPeriodArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupData()
    }
    
    func setupView() {
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
    }
    
    func setupData() {
        guard let safeEmploymentModel = employmentModel else { return }
        
        if safeEmploymentModel.paymentType == .hourly {
            guard let safeRate = hourlyRate else { return }

            
            rateNameTextField.text = safeRate.name
            payTitleTextField.text = String(safeRate.value)
            frequencyTextField.text = "payment_type_hourly".localized
            return
        }
        
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
