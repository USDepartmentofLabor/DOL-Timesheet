//
//  OnboardPayViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

enum ShownPicker {
    case payFrequencyPicker
    case payRateStart
    case statePicker
    case none
}

class OnboardPayViewController: OnboardBaseViewController {

    @IBOutlet weak var detailTitleLabel: UILabel!
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
    @IBOutlet weak var overtimeLabel: UILabel!
    @IBOutlet weak var overtimeSwitch: UISwitch!
    @IBOutlet weak var yesOvertimeButton: UIButton!
    @IBOutlet weak var noOvertimeButton: UIButton!
    
    @IBOutlet weak var stateTitle: UILabel!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var statePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var infoStateButton: UIButton!
    
    @IBOutlet weak var stateMinimumText: UILabel!
    @IBOutlet weak var stateMinimumField: UITextField!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var noteTitle: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    var pickerSelected = ShownPicker.none
    
    var timePickerVC = TimePickerViewController.instantiateFromStoryboard()
    
    var overtimeEligible: Bool = true
    
    var payPeriodArray: [String] = []
    
    //Checks for canMoveForward
    var stateValid: Bool = false
    var payRateValid: Bool = false
    var minimumWageValid: Bool = false
    var payRateTermValid: Bool = false
    var payPeriodValid: Bool = false
    
    var selectedPayFrequency: PaymentFrequency? = .daily
    var selectedState: State?
    var selectedPayPeriod: String?
    var selectedPayRate: Double = 0.0
    
    var stateMinWages: StateMinWage = StateMinWage.init()
//    weak var delegate: TimeViewControllerDelegate?
    
    var hourlyRate: HourlyRate? {
        didSet {
            displayHourlyRate()
        }
    }
    
    var minimumWage: NSNumber = 0.0 {
        didSet {
            if isViewLoaded {
                stateMinimumField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        canMoveForward = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            scrollViewBottomConstraint.constant = keyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset or handle the keyboard height as needed
        scrollViewBottomConstraint.constant = 174
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        payFrequencyPickerHeight.constant = 0
        statePickerHeight.constant = 0
        payPeriodPickerHeight.constant = 0
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        switch pickerSelected {
        case .payFrequencyPicker:
            if payFrequencyPicker.frame.contains(sender.location(in: view)) {
                if payFrequencyField.text?.count == 0 {
                    payFrequencyField.text? = PaymentFrequency.daily.title
                }
                payFrequencyPickerHeight.constant = 216
            }
        case .payRateStart:
            break
        case .statePicker:
            if statePicker.frame.contains(sender.location(in: view)) {
                if stateField.text?.count == 0 {
                    stateField.text? = "Alabama"
                    selectedState = State.states[0]
                    if let state = stateMinWages.data.first(where: { $0.state == State.states[0].title }),
                       let minWage = state.minimumWage {
                        minimumWage = minWage as NSNumber
                        stateMinimumField.text = String(NumberFormatter.localisedCurrencyStr(from: minWage))
                    }
                    stateValid = true
                }
                statePickerHeight.constant = 216
            }
        case .none:
            break
        }
        check()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupView()
        displayInfo()
        
        detailTitleLabel.text = NSLocalizedString("pay", comment: "Pay")
        if userType == .employee {
            payFrequencyTitle.text = "onboard_pay_frequency_employer".localized
            payRateTitle.text = "onboard_pay_rate_employer".localized
            overtimeTitle.text = "onboard_overtime_employer".localized
            stateTitle.text = "onboard_state_employer".localized
            stateMinimumText.text = "state_minimum_wage".localized
            

        } else {
            payFrequencyTitle.text = "onboard_pay_frequency_employee".localized
            payRateTitle.text = "onboard_pay_rate_employee".localized
            overtimeTitle.text = "onboard_overtime_employee".localized
            stateTitle.text = "onboard_state_employee".localized
            
        }
    }
    
    

    
    func deleteHourlyRate() {
        if employmentModel?.hourlyRates?.count != 0 {
            employmentModel?.deleteHourlyRate(hourlyRate: (employmentModel?.hourlyRates![0])!)
        }
    }
    
    override func setupView() {
        
        self.selectedPayPeriod = "payment_hour".localized
        
//        let rate = payRateField.text?.currencyAmount() ?? NSNumber(0)
//        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate)
                
        overtimeSwitch.isOn = true
        if (employmentModel?.overtimeEligible != true) {
            overtimeSwitch.isOn = false
        }
        
        self.overtimeSwicthPressed(overtimeSwitch!)

        
        payRateField.scaleFont(forDataType: .nameValueText)
        payRateField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        payFrequencyPickerHeight.constant = 0
        statePickerHeight.constant = 0
        payPeriodPickerHeight.constant = 0
        
        payPeriodArray = ["payment_hour".localized,
                          "salary_weekly".localized,
                          "salary_monthly".localized,
                          "salary_annually".localized]
        
        if userType == .employee {
            payFrequencyTitle.text = "onboard_pay_frequency_employer".localized
            payRateTitle.text = "onboard_pay_rate_employer".localized
            overtimeTitle.text = "onboard_overtime_employer".localized
            stateTitle.text = "onboard_state_employer".localized
        } else {
            payFrequencyTitle.text = "onboard_pay_frequency_employee".localized
            payRateTitle.text = "onboard_pay_rate_employee".localized
            overtimeTitle.text = "onboard_overtime_employee".localized
            stateTitle.text = "onboard_state_employee".localized
        }
        
        stateMinimumField.scaleFont(forDataType: .nameValueText)
        stateMinimumField.addTarget(self, action: #selector(minimumWageDidChange(_:)), for: .editingChanged)
        
        noteTitle.text = "onboard_pay_note".localized
        
        setupAccessibility()
        
        payRateField.setBorderColor()
        payFrequencyField.setBorderColor()
        payPeriodField.setBorderColor()
        stateField.setBorderColor()
        stateMinimumField.setBorderColor()
        
        stateMinimumField.delegate = self
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func setupAccessibility() {
        payRateField.accessibilityLabel = "rate_amount".localized
        stateMinimumField.accessibilityLabel = "minimum_wage_amount".localized

        if Util.isVoiceOverRunning {
            stateMinimumField.keyboardType = .numbersAndPunctuation
            payRateField.keyboardType = .numbersAndPunctuation
        }
    }

    func displayInfo() {
        stateMinimumField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
    }
    
    override func saveData() -> Bool  {
        print("OnboardPayViewController SAVE DATA")
        
        check()
        if !canMoveForward {
            return false
        }
        
        employmentModel?.paymentFrequency = selectedPayFrequency!
        employmentModel?.overtimeEligible = overtimeEligible
        employmentModel?.minimumWage = minimumWage
        
        employmentModel?.employmentInfo.startDate = Date()
        
        employmentModel?.paymentType = .salary
        if selectedPayPeriod! == "payment_hour".localized {
            employmentModel?.paymentType = .hourly
            if employmentModel?.hourlyRates?.count == 0 {
                employmentModel?.newHourlyRate()
            }
            employmentModel?.hourlyRates?[0].value = selectedPayRate
//            employmentModel?.hourlyRates?[0].createdAt = Date()
            
        } else if selectedPayPeriod! == "salary_weekly".localized {
            deleteHourlyRate()
            employmentModel?.salary = (amount: NSNumber(value: selectedPayRate), salaryType: .weekly)
        } else if selectedPayPeriod! == "salary_monthly".localized {
            deleteHourlyRate()
            employmentModel?.salary = (amount: NSNumber(value: selectedPayRate), salaryType: .monthly)
        } else if selectedPayPeriod! == "salary_annually".localized {
            deleteHourlyRate()
            employmentModel?.salary = (amount: NSNumber(value: selectedPayRate), salaryType: .annually)
        }
        
        let user = employmentModel?.employmentUser
        user?.setAddress(street1: " ", street2: " ", city: " ", state: selectedState?.title, zipCode: " ")
        
        return true
    }
    
    func check() {
        canMoveForward = true

        if userType == .employee {
            if (!stateValid || !payRateValid || !minimumWageValid || !payRateTermValid) {
                canMoveForward = false
            }
        } else {
            if (!payRateValid || !payRateTermValid) {
                canMoveForward = false
            }
        }
        onboardingDelegate?.updateCanMoveForward(value: canMoveForward)
    }
    
    func displayHourlyRate() {
        guard let rate = hourlyRate else { return }
        
        payRateField.text = rate.name
        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate.value)
        
    }
    
    override func resetData() {
        overtimeEligible = true
        
        payPeriodArray = []
        
        //Checks for canMoveForward
        stateValid = false
        payRateValid = false
        minimumWageValid = false
        payRateTermValid = false
        payPeriodValid = false
        
        selectedPayFrequency = .daily
        selectedState = nil
        selectedPayPeriod = nil
        selectedPayRate = 0.0
        
        hourlyRate = nil
        minimumWage = 0.0
        
        if payFrequencyField != nil {
            payFrequencyField.text = nil
            payRateField.text = "$0.00"
            payPeriodField.text = nil
            overtimeSwitch.isOn = true
            stateField.text = nil
            stateMinimumField.text = "0.00"
        }
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
    @IBAction func infoOvertimePressed(_ sender: Any) {
        displayInfoPopup(sender, info: .overtimeEligible)
    }
    
    @IBAction func overtimeSwicthPressed(_ sender: Any) {
        overtimeLabel.text = "onboard_overtime_no".localized
        overtimeEligible = false

        if overtimeSwitch.isOn {
            overtimeLabel.text = "onboard_overtime_yes".localized
            overtimeEligible = true
        }
    }
    
    @IBAction func yesOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor.white
        noOvertimeButton.backgroundColor = UIColor.white
        yesOvertimeButton.tintColor = UIColor(named: "onboardButtonColor")
        yesOvertimeButton.backgroundColor = UIColor(named: "onboardButtonColor")
        self.containerView.bringSubviewToFront(yesOvertimeButton)
        overtimeEligible = true
    }
    
    @IBAction func noOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor(named: "onboardButtonColor")
        noOvertimeButton.backgroundColor = UIColor(named: "onboardButtonColor")
        yesOvertimeButton.tintColor = UIColor.white
        yesOvertimeButton.backgroundColor = UIColor.white
        self.containerView.bringSubviewToFront(noOvertimeButton)
        overtimeEligible = false
    }
    
    @IBAction func infoStateButtonPressed(_ sender: Any) {
        displayInfoPopup(sender, info: .state)
    }
    
}

extension OnboardPayViewController: UITextFieldDelegate {
    
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
                if payFrequencyField.text?.count == 0 {
                    payFrequencyField.text? = PaymentFrequency.daily.title
                }
                payFrequencyPickerHeight.constant = 216
                statePickerHeight.constant = 0
                payPeriodPickerHeight.constant = 0
                pickerSelected = .payFrequencyPicker
            }
            check()
            return false
        } else if textField == stateField {
            if statePickerHeight.constant > 1 {
                statePickerHeight.constant = 0
            } else {
                if stateField.text?.count == 0 {
                    stateField.text? = "Alabama"
                    selectedState = State.states[0]
                    if let state = stateMinWages.data.first(where: { $0.state == State.states[0].title }),
                       let minWage = state.minimumWage {
                        minimumWage = minWage as NSNumber
                        stateMinimumField.text = String(NumberFormatter.localisedCurrencyStr(from: minWage))
                    }
                    stateValid = true
                    minimumWageValid = true
                }
                statePickerHeight.constant = 216
                payFrequencyPickerHeight.constant = 0
                payPeriodPickerHeight.constant = 0
                pickerSelected = .statePicker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.scrollView.scrollToBottom()
                }
            }
            check()
            return false
        } else if textField == payPeriodField {
            if payPeriodPickerHeight.constant > 1 {
                payPeriodPickerHeight.constant = 0
            } else {
                if payPeriodField.text?.count == 0 {
                    payPeriodField.text? = "payment_hour".localized
                    payRateTermValid = true
                }
                payPeriodPickerHeight.constant = 216
                payFrequencyPickerHeight.constant = 0
                statePickerHeight.constant = 0
                pickerSelected = .payFrequencyPicker
            }
            check()
            return false
        } else {
            return true
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}

extension OnboardPayViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedWeekday = Weekday.allCases[row]
        if pickerView == payFrequencyPicker {
            payFrequencyField.text = PaymentFrequency.allCases[row].title
            selectedPayFrequency = PaymentFrequency.allCases[row]
        } else if pickerView == statePicker {
            stateField.text = State.states[row].title
            selectedState = State.states[row]
            if let state = stateMinWages.data.first(where: { $0.state == State.states[row].title }),
               let minWage = state.minimumWage {
                minimumWage = minWage as NSNumber
                stateMinimumField.text = String(NumberFormatter.localisedCurrencyStr(from: minWage))
            }
            stateValid = true
            
            minimumWage = stateMinimumField.text?.currencyAmount() ?? NSNumber(0)
            stateMinimumField.setBorderColor()
//            if minimumWage.doubleValue < 7.25 {
//                stateMinimumField.setErrorBorderColor()
//            }
            
            minimumWageValid = true
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

extension OnboardPayViewController: UIPickerViewDataSource {
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

extension OnboardPayViewController {
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

extension OnboardPayViewController {
    func validateInput() -> String? {
        
        var errorStr: String? = nil
            // Minimum Wage should be greater than 0
        if minimumWage.compare(NSNumber(0)) != .orderedDescending {
            errorStr = "err_enter_valid_minimum_wage".localized
        }
        
        return errorStr
    }
}

extension OnboardPayViewController {
    @objc func minimumWageDidChange(_ textField: UITextField) {
        minimumWage = textField.text?.currencyAmount() ?? NSNumber(0)
        textField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
        
        stateMinimumField.setBorderColor()
//        if minimumWage.doubleValue < 7.25 {
//            stateMinimumField.setErrorBorderColor()
//        }
        
        minimumWageValid = true
        check()
    }
}
