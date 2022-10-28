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
    @IBOutlet weak var payRateField: UnderlinedTextField!
    
    @IBOutlet weak var payPeriodField: UITextField!
    @IBOutlet weak var payPeriodPicker: UIPickerView!
    @IBOutlet weak var payRateStart: UIDatePicker!
    @IBOutlet weak var payPeriodPickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var overtimeTitle: UILabel!
    @IBOutlet weak var infoOvertimeButton: UIButton!
    @IBOutlet weak var yesOvertimeButton: UIButton!
    @IBOutlet weak var noOvertimeButton: UIButton!
    
    @IBOutlet weak var dontRoundUpDownButton: UIButton!
    @IBOutlet weak var roundUpDownButton: UIButton!
    
    @IBOutlet weak var stateTitle: UILabel!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var statePickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var noteTitle: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
    
    var overtimeEligible: Bool = true
    var roundTimeUp: Bool = true
    
    var payPeriodArray: [String] = []
    
    //Checks for canMoveForward
    var stateValid: Bool = false
    var payRateValid: Bool = false
    //var frequencyValid: Bool = false
    //var payPeriodValid: Bool = false
    
    var selectedPayFrequency: PaymentFrequency? = .daily
    var selectedState: State?
    var selectedPayPeriod: String? = NSLocalizedString("payment_type_hourly", comment: "")
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
        canMoveForward = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userType == .employee {
            payFrequencyTitle.text = "How often do you get paid?"
            payRateTitle.text = "What is your pay rate?"
            overtimeTitle.text = "Are you eligible for paid overtime?"
            stateTitle.text = "What state do you work in?"

        } else {
            payFrequencyTitle.text = "How often do your employee get paid?"
            payRateTitle.text = "What is your employee's pay rate?"
            overtimeTitle.text = "Is your employee eligible for paid overtime?"
            stateTitle.text = "What state does your employee work in?"
        }
    }

    
    func deleteHourlyRate() {
        if employmentModel?.hourlyRates?.count != 0 {
            employmentModel?.deleteHourlyRate(hourlyRate: (employmentModel?.hourlyRates![0])!)
        }
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        let rate = payRateField.text?.currencyAmount() ?? NSNumber(0)
        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate)
        
        payFrequencyField.text = NSLocalizedString("payment_frequency_daily", comment: "")
        payPeriodField.text = NSLocalizedString("payment_type_hourly", comment: "")
        
        if (employmentModel?.overtimeEligible == true) {
            self.yesOvertimeButtonPressed(yesOvertimeButton!)
        } else {
            self.noOvertimeButtonPressed(noOvertimeButton!)
        }
        
        payRateField.scaleFont(forDataType: .nameValueText)
        payRateField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        payFrequencyPickerHeight.constant = 0
        statePickerHeight.constant = 0
        payPeriodPickerHeight.constant = 0
        
        payPeriodArray = [NSLocalizedString("payment_type_hourly", comment: ""),
                          NSLocalizedString("salary_weekly", comment: ""),
                          NSLocalizedString("salary_monthly", comment: ""),
                          NSLocalizedString("salary_annually", comment: "")]
        
        if userType == .employee {
            payFrequencyTitle.text = NSLocalizedString("onboard_pay_frequency_employer", comment: "How often do you get paid?")
            payRateTitle.text = NSLocalizedString("onboard_pay_rate_employer", comment: "What is your pay rate?")
            overtimeTitle.text = NSLocalizedString("onboard_overtime_employer", comment: "Are you eligible for paid overtime?")
            stateTitle.text = NSLocalizedString("onboard_state_employer", comment: "What state do you work in?")
        } else {
            payFrequencyTitle.text = NSLocalizedString("onboard_pay_frequency_employee", comment: "How often does your employee get paid?")
            payRateTitle.text = NSLocalizedString("onboard_pay_rate_employee", comment: "What is your employee's pay rate?")
            overtimeTitle.text = NSLocalizedString("onboard_overtime_employee", comment: "What is your employee paid time?")
            stateTitle.text = NSLocalizedString("onboard_state_employee", comment: "What state does your employee work in?")
        }
        
        yesOvertimeButton.setTitle(NSLocalizedString("onboard_overtime_yes", comment: "Yes (non-exempt)"), for: .normal)
        noOvertimeButton.setTitle(NSLocalizedString("onboard_overtime_no", comment: "No (exempt)"), for: .normal)
        noteTitle.text = NSLocalizedString("onboard_pay_note", comment: "")
        
        setupAccessibility()
        
        payRateField.setBorderColor()
        payFrequencyField.setBorderColor()
        payPeriodField.setBorderColor()
        stateField.setBorderColor()
        
      //  roundUpDownButton.titleLabel?.font = .systemFont(ofSize: 10)
       // roundUpDownButton.titleLabel?.font = UIFont(name: "System", size: 10)
        
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func setupAccessibility() {
//        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
        
        payRateField.accessibilityLabel = NSLocalizedString("rate_amount", comment: "Rate Amount")
        
        if Util.isVoiceOverRunning {
            payRateField.keyboardType = .numbersAndPunctuation
        }
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
    
    override func saveData() {
        print("OnboardDetailsViewController SAVE DATA")
        employmentModel?.paymentFrequency = selectedPayFrequency!
        employmentModel?.overtimeEligible = overtimeEligible
        
        employmentModel?.paymentType = .salary
        if selectedPayPeriod! == NSLocalizedString("payment_type_hourly", comment: "") {
            employmentModel?.paymentType = .hourly
            if employmentModel?.hourlyRates?.count == 0 {
                employmentModel?.newHourlyRate()
            }
            employmentModel?.hourlyRates?[0].value = selectedPayRate
//            employmentModel?.hourlyRates?[0].createdAt = Date()
            
        } else if selectedPayPeriod! == NSLocalizedString("salary_weekly", comment: "") {
            deleteHourlyRate()
            employmentModel?.salary = (amount: NSNumber(value: selectedPayRate), salaryType: .weekly)
        } else if selectedPayPeriod! == NSLocalizedString("salary_monthly", comment: "") {
            deleteHourlyRate()
            employmentModel?.salary = (amount: NSNumber(value: selectedPayRate), salaryType: .monthly)
        } else if selectedPayPeriod! == NSLocalizedString("salary_annually", comment: "") {
            deleteHourlyRate()
            employmentModel?.salary = (amount: NSNumber(value: selectedPayRate), salaryType: .annually)
        }
        
        let user = employmentModel?.employmentUser
        user?.setAddress(street1: " ", street2: " ", city: " ", state: selectedState!.title, zipCode: " ")
    }
    
    func check() {
        if (stateValid && payRateValid) {
            canMoveForward = true
        } else {
            canMoveForward = false
        }
        onboardingDelegate?.updateCanMoveForward(value: canMoveForward)
    }
    
    func displayHourlyRate() {
        guard let rate = hourlyRate else { return }
        
        payRateField.text = rate.name
        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate.value)
        
    }
    @IBAction func infoFrequencyPressed(_ sender: Any) {
        if userType == .employee {
            displayInfoPopup(sender, info: .employee_paymentFrequency)
        } else {
            displayInfoPopup(sender, info: .employer_paymentFrequency)
        }
    }
    @IBAction func infoPayRatePressed(_ sender: Any) {
        if userType == .employee {
            displayInfoPopup(sender, info: .employee_hourlyPayRate)
        } else {
            displayInfoPopup(sender, info: .employer_hourlyPayRate)
        }
    }
    
    @IBAction func roundUpDownPressed(_ sender: Any) {
        if roundTimeUp {
            displayInfoPopup(sender, info: .round_updown)
        } else {
            displayInfoPopup(sender, info: .dont_round_updown)
        }
    }
    @IBAction func infoOvertimePressed(_ sender: Any) {
        displayInfoPopup(sender, info: .overtimeEligible)
    }
    
    @IBAction func yesOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor.white
        yesOvertimeButton.tintColor = UIColor(named: "appPrimaryColor")
        self.containerView.bringSubviewToFront(yesOvertimeButton)
        overtimeEligible = true
    }
    
    @IBAction func noOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor(named: "appPrimaryColor")
        yesOvertimeButton.tintColor = UIColor.white
        self.containerView.bringSubviewToFront(noOvertimeButton)
        overtimeEligible = false
    }
    
    @IBAction func roundTimeUpDown(_ sender: Any) {
        dontRoundUpDownButton.tintColor = UIColor.white
        roundUpDownButton.tintColor = UIColor(named: "appPrimaryColor")
        self.containerView.bringSubviewToFront(roundUpDownButton)
        roundTimeUp = true
    }
    
    @IBAction func dontRoundUpDown(_ sender: Any) {
        dontRoundUpDownButton.tintColor = UIColor(named: "appPrimaryColor")
        roundUpDownButton.tintColor = UIColor.white
        self.containerView.bringSubviewToFront(dontRoundUpDownButton)
        roundTimeUp = false
    }
}

extension OnboardDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if ((textField.text?.isEmpty) == nil) { return false }
        
        selectedPayRate = Double(textField.text ?? "0.0") ?? 0.00
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == payFrequencyField {
            if payFrequencyPickerHeight.constant > 1 {
                payFrequencyPickerHeight.constant = 0
            } else {
                payFrequencyPickerHeight.constant = 216
                statePickerHeight.constant = 0
                payPeriodPickerHeight.constant = 0
            }
            return false
        } else if textField == stateField {
            if statePickerHeight.constant > 1 {
                statePickerHeight.constant = 0
            } else {
                statePickerHeight.constant = 216
                payFrequencyPickerHeight.constant = 0
                payPeriodPickerHeight.constant = 0
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
                payFrequencyPickerHeight.constant = 0
                statePickerHeight.constant = 0
            }
            return false
        } else {
            return true
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
//            frequencyValid = true
        } else if pickerView == statePicker {
            stateField.text = State.states[row].title
            selectedState = State.states[row]
            stateValid = true
        } else {
            payPeriodField.text = payPeriodArray[row]
            selectedPayPeriod = payPeriodArray[row]
//            payPeriodValid = true
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

extension OnboardDetailsViewController {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == payRateField {
            let rate = textField.text?.currencyAmount() ?? NSNumber(0)
            textField.text = NumberFormatter.localisedCurrencyStr(from: rate)
            hourlyRate?.value = rate.doubleValue
            selectedPayRate = rate.doubleValue
            payRateValid = true
            check()
        }
    }
}
