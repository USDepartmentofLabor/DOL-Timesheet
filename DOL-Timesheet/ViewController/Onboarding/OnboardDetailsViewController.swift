//
//  OnboardDetailsViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardDetailsViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var payFrequencyTitle: UILabel!
    @IBOutlet weak var infoFrequencyButton: UIButton!
    
    @IBOutlet weak var payFrequencyField: UITextField!
    @IBOutlet weak var payFrequencyPicker: UIPickerView!
    @IBOutlet weak var payFrequencyPickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var payRateTitle: UILabel!
    @IBOutlet weak var infoPayRateButton: UIButton!
    @IBOutlet weak var payRateField: UITextField!
    
    @IBOutlet weak var payPeriodField: UITextField!
    @IBOutlet weak var payPeriodPicker: UIPickerView!
    @IBOutlet weak var payRateStart: UIDatePicker!
    @IBOutlet weak var payPeriodPickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var overtimeTitle: UILabel!
    @IBOutlet weak var infoOvertimeButton: UIButton!
    @IBOutlet weak var yesOvertimeButton: UIButton!
    @IBOutlet weak var noOvertimeButton: UIButton!
    
    @IBOutlet weak var stateTitle: UILabel!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var statePickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var noteTitle: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
    
    var payPeriodArray: [String] = []
    var frequencyValid: Bool = false
    var overtimeEligible: Bool = true
    var stateValid: Bool = false
    var payPeriodValid: Bool = false
    var payRateValid: Bool = false
    
    var selectedPayFrequency: PaymentFrequency?
    var selectedState: State?
    var selectedPayPeriod: String?
    var selectedPayRate: Double = 0.0
//    weak var delegate: TimeViewControllerDelegate?
    
    var hourlyRate: HourlyRate? {
        didSet {
            displayHourlyRate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        canMoveForward = true
    }
    
    override func saveData() {
        print("OnboardDetailsViewController SAVE DATA")
        employmentModel?.paymentFrequency = selectedPayFrequency!
        employmentModel?.overtimeEligible = overtimeEligible
        
        employmentModel?.paymentType = .salary
        if selectedPayPeriod! == NSLocalizedString("payment_type_hourly", comment: "") {
            employmentModel?.paymentType = .hourly
            employmentModel?.newHourlyRate()
            employmentModel?.hourlyRates?[0].value = selectedPayRate
            
        } else if selectedPayPeriod! == NSLocalizedString("salary_weekly", comment: "") {
            employmentModel?.salary.salaryType = .weekly
        } else if selectedPayPeriod! == NSLocalizedString("salary_monthly", comment: "") {
            employmentModel?.salary.salaryType = .monthly
        } else if selectedPayPeriod! == NSLocalizedString("salary_annually", comment: "") {
            employmentModel?.salary.salaryType = .annually
        }
        
        let user = employmentModel?.employmentUser
        user?.setAddress(street1: " ", street2: " ", city: " ", state: selectedState!.title, zipCode: " ")
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        if (employmentModel?.overtimeEligible == true) {
            self.yesOvertimeButtonPressed(yesOvertimeButton!)
        } else {
            self.noOvertimeButtonPressed(noOvertimeButton!)
        }
        
        payFrequencyPickerHeight.constant = 0
        statePickerHeight.constant = 0
        payPeriodPickerHeight.constant = 0
        
        payPeriodArray = [NSLocalizedString("payment_type_hourly", comment: ""),
                          NSLocalizedString("salary_weekly", comment: ""),
                          NSLocalizedString("salary_monthly", comment: ""),
                          NSLocalizedString("salary_annually", comment: "")]
        
        setupAccessibility()
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func setupAccessibility() {
//        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
//        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
//        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
//        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setupProfile",
//            let setupVC = segue.destination as? SetupProfileViewController {
//            setupVC.delegate = delegate
//        }
//    }
    
    func check() {
//        if (nameValid && otherNameValid && workWeekStartValid) {
            canMoveForward = true
//        } else {
//            canMoveForward = false
//        }
        onboardingDelegate?.updateCanMoveForward(value: canMoveForward)
    }
    
    func displayHourlyRate() {
        guard let rate = hourlyRate else { return }
        
        payRateField.text = rate.name
        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate.value)
        
    }
    
    @IBAction func yesOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor.white
        yesOvertimeButton.tintColor = UIColor.systemBlue
        self.containerView.bringSubviewToFront(yesOvertimeButton)
        overtimeEligible = true
    }
    
    @IBAction func noOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor.systemBlue
        yesOvertimeButton.tintColor = UIColor.white
        self.containerView.bringSubviewToFront(noOvertimeButton)
        overtimeEligible = false
    }
}

extension OnboardDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if ((textField.text?.isEmpty) != nil) { return false }
        
        selectedPayRate = Double(textField.text ?? "0.0") ?? 0.00
        payRateValid = true
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == payFrequencyField {
            if payFrequencyPickerHeight.constant > 1 {
                payFrequencyPickerHeight.constant = 0
            } else {
                payFrequencyPickerHeight.constant = 216
            }
            return false
        } else if textField == stateField {
            if statePickerHeight.constant > 1 {
                statePickerHeight.constant = 0
            } else {
                statePickerHeight.constant = 216
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.scrollView.scrollToBottom()
                }
            }
            return false
        } else if textField == payPeriodField {
            if payPeriodPickerHeight.constant > 1 {
                payPeriodPickerHeight.constant = 0
            } else {
                payPeriodPickerHeight.constant = 216
            }
            return false
        } else {
            return true
        }
    }
    func textFieldDidChange(_ textField: UITextField) {
        if textField == payRateField {
            let rate = textField.text?.currencyAmount() ?? NSNumber(0)
            textField.text = NumberFormatter.localisedCurrencyStr(from: rate)
            hourlyRate?.value = rate.doubleValue
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == stateTextField {
//
//            let announcementMsg = NSLocalizedString("select_state", comment: "Select State")
//            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementMsg)
//
//            DispatchQueue.main.async { [weak self] in
//                self?.view.endEditing(true)
//            }
//
//            let optionsVC = OptionsListViewController(options: State.states, title: "States")
//            optionsVC.didSelect = { [weak self] (popVC: UIViewController, state: State?) in
//                guard let strongSelf = self else { return }
//                if let state = state {
//                    strongSelf.stateTextField.text = state.title
//                }
//                optionsVC.dismiss(animated: true, completion: nil)
//                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: strongSelf.zipcodeTextField)
//
//            }
//
//            showPopup(popupController: optionsVC, sender: textField)
//        }
    }
}

extension OnboardDetailsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedWeekday = Weekday.allCases[row]
        if pickerView == payFrequencyPicker {
            payFrequencyField.text = PaymentFrequency.allCases[row].title
            selectedPayFrequency = PaymentFrequency.allCases[row]
            frequencyValid = true
        } else if pickerView == statePicker {
            stateField.text = State.states[row].title
            selectedState = State.states[row]
            stateValid = true
        } else {
            payPeriodField.text = payPeriodArray[row]
            selectedPayPeriod = payPeriodArray[row]
            payPeriodValid = true
        }
        check()
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == payFrequencyPicker {
            return PaymentFrequency.allCases[row].title
        } else if pickerView == statePicker {
            return State.states[row].title
        } else {
            return payPeriodArray[row]
        }
    }
}

extension OnboardDetailsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == payFrequencyPicker {
            return PaymentFrequency.allCases.count
        } else if pickerView == statePicker {
            return State.states.count
        } else{
            return payPeriodArray.count
        }
    }
}
