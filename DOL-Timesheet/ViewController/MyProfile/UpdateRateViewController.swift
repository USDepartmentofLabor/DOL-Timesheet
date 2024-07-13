//
//  UpdateRateViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

struct TempRate {
    var rateName: String = ""
    var rateValue: Double = 0.0
    var type: PaymentType = .hourly
    var frequency: SalaryType = .weekly
}

protocol UpdateRateDelegate: AnyObject {
    func rateUpdated(_ rate: TempRate)
    func rateDelete()
}

class UpdateRateViewController: UIViewController {
    
    var tempRate: TempRate?
    weak var delegate: UpdateRateDelegate?
    
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
    
    var payFrequencyArray: [String] = []
    
    
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
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            // Back button pressed
            handleBackButton()
        }
    }

    func handleBackButton() {
      //  validateInput()
    }
    
    func getSalaryType(_ freqText: String)-> SalaryType {
        if freqText == SalaryType.weekly.title {
            return .weekly
        } else if freqText == SalaryType.monthly.title {
            return .monthly
        } else {
            return .annually
        }
    }
    
    func getFrequencyName(rate: TempRate)-> String {
        
        if rate.type == .hourly {
            return "payment_type_hourly".localized
        } else if rate.frequency == .weekly {
            return  SalaryType.weekly.title
        } else if rate.frequency == .monthly {
            return SalaryType.monthly.title
        } else {
            return  SalaryType.annually.title
        }
    }
    
    func setFrequencyPicker(rate: TempRate) {
        
        if rate.type == .hourly {
            frequencyPicker.selectRow(0, inComponent: 0, animated: false)
        } else if rate.frequency == .weekly {
            frequencyPicker.selectRow(1, inComponent: 0, animated: false)
        } else if rate.frequency == .monthly {
            frequencyPicker.selectRow(2, inComponent: 0, animated: false)
        } else {
            frequencyPicker.selectRow(3, inComponent: 0, animated: false)
        }
    }
    
    func validateError(message: String) {
        let alertController = UIAlertController(title: "error_title".localized, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alertController, animated: true)
    }
    
    func setupView() {
        title = "new_rate".localized
        
        rateNameTitleLabel.text = "rate_name".localized
        payTitleLabel.text = "pay".localized
        frequencyTitleLabel.text = "frequency".localized
        
        payFrequencyArray = ["payment_type_hourly".localized,
                             SalaryType.weekly.title,
                             SalaryType.monthly.title,
                             SalaryType.annually.title]
        
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
        
        if tempRate == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save",
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
        }
        discardButton.isHidden = true
    }
    
    func setupData() {
        if let rate = tempRate {
            title = rate.rateName
            rateNameTextField.text = rate.rateName
            payTitleTextField.text = String(rate.rateValue)
            frequencyTextField.text = getFrequencyName(rate: rate)
            setFrequencyPicker(rate: rate)
            discardButton.isHidden = true
            setupNormalMode()
            return
        }
        discardButton.isHidden = true
    }
    
    @objc func editButtonTapped() {
        if navigationItem.rightBarButtonItem?.title == "Edit" {
            setupEditMode()
        } else {
            if validateInput() {
                setupNormalMode()
            }
        }
    }
    
    @objc func cancelPressed() {
        setupNormalMode()
    }
    
    func setupEditMode() {
        navigationItem.rightBarButtonItem?.title = "Save"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                  title: "Cancel",
                  style: .plain,
                  target: self,
                  action: #selector(cancelPressed)
              )

        rateNameTextField.textColor = UIColor(named: "valueActiveText")
        rateNameTextField.isEnabled = true
        payTitleTextField.textColor = UIColor(named: "valueActiveText")
        payTitleTextField.isEnabled = true
        frequencyTextField.textColor = UIColor(named: "valueActiveText")
        frequencyTextField.isEnabled = true
        
        discardButton.isHidden = false
    }
    
    func setupNormalMode() {
        navigationItem.rightBarButtonItem?.title = "Edit"
        navigationItem.leftBarButtonItem = nil
        
        rateNameTextField.textColor = UIColor(named: "valueInactiveText")
        rateNameTextField.isEnabled = false
        payTitleTextField.textColor = UIColor(named: "valueInactiveText")
        payTitleTextField.isEnabled = false
        frequencyTextField.textColor = UIColor(named: "valueInactiveText")
        frequencyTextField.isEnabled = false
        discardButton.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "updateRateHelpScreen",
            let helpVC = segue.destination as? HelpTableViewController {
            helpVC.helpItems = [
                HelpItem(title: "pay_rate".localized, body: "info_employee_hourly_pay_rate".localized),
                HelpItem(title: "pay_type".localized, body: "info_employee_payment_type".localized)]
        }
    }
    
    @IBAction func discardPressed(_ sender: Any) {
        
        guard let freqText = frequencyTitleLabel.text else { return }
        
        var title = "delete_hourly_rate".localized
        var message = "delete_hourly_rate_warning".localized
        
        if freqText != "payment_type_hourly".localized {
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
                self.delegate?.rateDelete()
                self.navigationController?.popViewController(animated: true)
            }
        )
        present(alertController, animated: true)
    }
    
    
    func validateInput()->Bool {
        guard let freqText = frequencyTextField.text,
              let payText = payTitleTextField.text,
              let rateNameText = rateNameTextField.text else { return false }
        
        if rateNameText.isEmpty && freqText == "payment_type_hourly".localized {
            validateError(message: "rate_name_not_specified".localized)
            return false
        }
        
        if payText.isEmpty {
            validateError(message: "pay_not_specified".localized)
            return false
        }
        
        if freqText.isEmpty {
            validateError(message: "pay_frequency_not_selected".localized)
            return false
        }
        
        if freqText == "payment_type_hourly".localized  {
            if tempRate == nil { tempRate = TempRate(type: .hourly) }
            if tempRate!.type == .hourly {
                tempRate!.rateName = rateNameText
                tempRate!.rateValue = Double(payText) ?? 0.0
                delegate?.rateUpdated(tempRate!)
                return true
            } else {
                let alertController = UIAlertController(title: "warning".localized, message: "switching_from_salary", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK".localized, style: .destructive){_ in
                    self.tempRate!.type = .hourly
                    self.tempRate!.rateName = rateNameText
                    self.tempRate!.rateValue = Double(payText) ?? 0.0
                    self.delegate?.rateUpdated(self.tempRate!)
                    self.setupNormalMode()
                })
                alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive))
                present(alertController, animated: true)
                return false
            }
        } else { // Salary Now Specified
            if tempRate == nil { tempRate = TempRate(type: .salary) }
            if tempRate!.type == .salary {
                tempRate!.frequency = getSalaryType(freqText)
                tempRate!.rateValue = Double(payText) ?? 0.0
                delegate?.rateUpdated(tempRate!)
                return true
            } else {
                let alertController = UIAlertController(title: "warning".localized, message: "switching_from_hourly", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK".localized, style: .destructive){_ in
                    self.tempRate!.type = .salary
                    self.tempRate!.rateName = rateNameText
                    self.tempRate!.frequency = self.getSalaryType(freqText)
                    self.tempRate!.rateValue = Double(payText) ?? 0.0
                    self.delegate?.rateUpdated(self.tempRate!)
                    self.setupNormalMode()
                })
                alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .destructive))
                present(alertController, animated: true)
                return false
            }
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
                    frequencyTextField.text? = "payment_type_hourly".localized
                }
                frequencyPickerHeightConstraint.constant = 216
            }
            return false
        } else if textField == payTitleTextField {
            guard let freqText = frequencyTitleLabel.text else { return false}
            if freqText != "payment_type_hourly".localized {
                return false
            }
            return true
        }
        
        frequencyPickerHeightConstraint.constant = 0
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}

extension UpdateRateViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        frequencyTextField.text = payFrequencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return payFrequencyArray[row]
    }
}

extension UpdateRateViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return payFrequencyArray.count
    }
}
