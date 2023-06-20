//
//  OnboardDetailsViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

enum ShownPicker {
    case payFrequencyPicker
    case payPeriodPicker
    case payRateStart
    case statePicker
    case none
}

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
    
    @IBOutlet weak var firstDayPeriodText: UILabel!
    @IBOutlet weak var firstPayPeriodField: UITextField!
    
    @IBOutlet weak var overtimeTitle: UILabel!
    @IBOutlet weak var infoOvertimeButton: UIButton!
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
    
    @IBOutlet weak var firstDayView: UIView!
    @IBOutlet weak var firstDayDatePicker: UIDatePicker!
    @IBOutlet weak var firstDayViewHeightConstraint: NSLayoutConstraint!
    
    var pickerSelected = ShownPicker.none
    
    var timePickerVC = TimePickerViewController.instantiateFromStoryboard()
    var dateFormatter = DateFormatter()
    
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
    var selectedPayPeriod: String? = NSLocalizedString("payment_type_hourly", comment: "")
    var selectedPayRate: Double = 0.0
    var firstPayPeriod: Date?
    
    let firstDayViewHeightWithPicker:CGFloat = 275
    let firstDayViewHeightWithField:CGFloat = 80
    let firstDayViewHeightHidden:CGFloat = 0
    
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
        setupView()
        displayInfo()
        canMoveForward = false
        self.setupFieldTap()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        firstDayPeriodText.text = NSLocalizedString("First day of your pay period", comment: "First day of your pay period")
        
        firstDayViewHeightConstraint.constant = firstDayViewHeightHidden
        firstDayView.isHidden = true
        
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
        if (selectedPayFrequency == .biWeekly) {
            firstDayViewHeightConstraint.constant = firstDayViewHeightWithField
            firstDayDatePicker.isHidden = true
            firstDayView.isHidden = false
        } else {
            firstDayViewHeightConstraint.constant = firstDayViewHeightHidden
            firstDayView.isHidden = true
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        switch pickerSelected {
        case .payFrequencyPicker:
            if payFrequencyPicker.frame.contains(sender.location(in: view)) {
                if payFrequencyField.text?.count == 0 {
                    payFrequencyField.text? = PaymentFrequency.daily.title
                }
                payFrequencyPickerHeight.constant = 216
            }
        case .payPeriodPicker:
            if payPeriodPicker.frame.contains(sender.location(in: view)) {
                if payPeriodField.text?.count == 0 {
                    payPeriodField.text? = NSLocalizedString("payment_type_hourly", comment: "Hourly")
                    payRateTermValid = true
                }
                payPeriodPickerHeight.constant = 216
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
        
        if userType == .employee {
            payFrequencyTitle.text = NSLocalizedString("onboard_pay_frequency_employer", comment: "How often do you get paid?")
            payRateTitle.text = NSLocalizedString("onboard_pay_rate_employer", comment: "What is your pay rate?")
            overtimeTitle.text = NSLocalizedString("onboard_overtime_employer", comment: "Are you eligible for paid overtime?")
            stateTitle.text = NSLocalizedString("onboard_state_employer", comment: "What state do you work in?")
            stateMinimumText.text = NSLocalizedString("state_minimum_wage", comment: "State minimum wage")
            
            stateMinimumText.isHidden = false
            stateMinimumField.isHidden = false
            
            stateField.isHidden = false
            stateTitle.isHidden = false
            infoStateButton.isHidden = false

        } else {
            payFrequencyTitle.text = NSLocalizedString("onboard_pay_frequency_employee", comment: "How often does your employee get paid?")
            payRateTitle.text = NSLocalizedString("onboard_pay_rate_employee", comment: "What is your employee's pay rate?")
            overtimeTitle.text = NSLocalizedString("onboard_overtime_employee", comment: "Is your employee eligible for paid time?")
            stateTitle.text = NSLocalizedString("onboard_state_employee", comment: "The state your employee work in?")
            
            stateMinimumText.isHidden = true
            stateMinimumField.isHidden = true
            
            stateField.isHidden = true
            stateTitle.isHidden = true
            infoStateButton.isHidden = true
        }
        
        if (selectedPayFrequency == .biWeekly) {
            firstDayViewHeightConstraint.constant = firstDayViewHeightWithField
            firstDayView.isHidden = false
            firstDayDatePicker.isHidden = true
        }
        
    }
    
    

    
    func deleteHourlyRate() {
        if employmentModel?.hourlyRates?.count != 0 {
            employmentModel?.deleteHourlyRate(hourlyRate: (employmentModel?.hourlyRates![0])!)
        }
    }
    
    override func setupView() {
        
        let rate = payRateField.text?.currencyAmount() ?? NSNumber(0)
        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate)
                
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
        
        stateMinimumField.addTarget(self, action: #selector(minimumWageDidChange(_:)), for: .editingChanged)
        
        yesOvertimeButton.setTitle(NSLocalizedString("onboard_overtime_yes", comment: "Yes (non-exempt)"), for: .normal)
        noOvertimeButton.setTitle(NSLocalizedString("onboard_overtime_no", comment: "No (exempt)"), for: .normal)
        noteTitle.text = NSLocalizedString("onboard_pay_note", comment: "")
        
        setupAccessibility()
        
        payRateField.setBorderColor()
        payFrequencyField.setBorderColor()
        payPeriodField.setBorderColor()
        stateField.setBorderColor()
        firstPayPeriodField.setBorderColor()
        stateMinimumField.setBorderColor()
        
        stateMinimumField.delegate = self
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func setupAccessibility() {
        payRateField.accessibilityLabel = NSLocalizedString("rate_amount", comment: "Rate Amount")
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
        print("OnboardDetailsViewController SAVE DATA")
        
        check()
        if !canMoveForward {
            return false
        }
        
        employmentModel?.paymentFrequency = selectedPayFrequency!
        employmentModel?.overtimeEligible = overtimeEligible
        employmentModel?.minimumWage = minimumWage
        
        employmentModel?.employmentInfo.startDate = Date()
        if selectedPayFrequency == .biWeekly {
            employmentModel?.employmentInfo.startDate = firstPayPeriod
        }
        
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
        if selectedPayFrequency == .biWeekly && firstPayPeriod == nil {
            canMoveForward = false
        }
        onboardingDelegate?.updateCanMoveForward(value: canMoveForward)
    }
    
    func displayHourlyRate() {
        guard let rate = hourlyRate else { return }
        
        payRateField.text = rate.name
        payRateField.text = NumberFormatter.localisedCurrencyStr(from: rate.value)
        
    }
    
    func setupFieldTap() {
        let fieldTap = UITapGestureRecognizer(target: self, action: #selector(self.fieldTapped(_:)))
        self.firstPayPeriodField.isUserInteractionEnabled = true
        self.firstPayPeriodField.addGestureRecognizer(fieldTap)
    }
    
    @objc func fieldTapped(_ sender: UITapGestureRecognizer) {
        if (firstDayViewHeightConstraint.constant == firstDayViewHeightWithPicker) {
            firstDayViewHeightConstraint.constant = firstDayViewHeightWithField
            firstDayView.isHidden = false
            firstDayDatePicker.isHidden = true
        } else {
            firstDayViewHeightConstraint.constant = firstDayViewHeightWithPicker
            firstDayView.isHidden = false
            firstDayDatePicker.isHidden = false
            firstDayDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
            firstDayDatePicker.preferredDatePickerStyle = .wheels
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
    
    @IBAction func yesOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor.white
        noOvertimeButton.backgroundColor = UIColor.white
        noOvertimeButton.setTitleColor(UIColor.black, for: .normal)
        yesOvertimeButton.tintColor = UIColor(named: "onboardButtonColor")
        yesOvertimeButton.backgroundColor = UIColor(named: "onboardButtonColor")
        yesOvertimeButton.setTitleColor(UIColor.white, for: .normal)
        self.containerView.bringSubviewToFront(yesOvertimeButton)
        overtimeEligible = true
    }
    
    @IBAction func noOvertimeButtonPressed(_ sender: Any) {
        noOvertimeButton.tintColor = UIColor(named: "onboardButtonColor")
        noOvertimeButton.backgroundColor = UIColor(named: "onboardButtonColor")
        noOvertimeButton.setTitleColor(UIColor.white, for: .normal)
        yesOvertimeButton.tintColor = UIColor.white
        yesOvertimeButton.backgroundColor = UIColor.white
        yesOvertimeButton.setTitleColor(UIColor.black, for: .normal)
        self.containerView.bringSubviewToFront(noOvertimeButton)
        overtimeEligible = false
    }
    
    @IBAction func infoStateButtonPressed(_ sender: Any) {
        displayInfoPopup(sender, info: .state)
    }
    
}

extension OnboardDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if ((textField.text?.isEmpty) == nil) { return false }
        
        selectedPayRate = Double(textField.text ?? "0.0") ?? 0.00
        
        return true
    }
    
    func hideFirstDatePayPeriodIfNecessary() {
        if selectedPayFrequency == .biWeekly {
            firstDayViewHeightConstraint.constant = firstDayViewHeightWithField
            firstDayDatePicker.isHidden = true
            firstDayView.isHidden = false
        }
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
                hideFirstDatePayPeriodIfNecessary()
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
                        stateMinimumField.text = String(NumberFormatter.localisedCurrencyStr(from: minWage))
                    }
                    stateValid = true
                    minimumWageValid = true
                }
                statePickerHeight.constant = 216
                payFrequencyPickerHeight.constant = 0
                payPeriodPickerHeight.constant = 0
                hideFirstDatePayPeriodIfNecessary()
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
                    payPeriodField.text? = NSLocalizedString("payment_type_hourly", comment: "Hourly")
                    payRateTermValid = true
                }
                payPeriodPickerHeight.constant = 216
                payFrequencyPickerHeight.constant = 0
                statePickerHeight.constant = 0
                hideFirstDatePayPeriodIfNecessary()
                pickerSelected = .payPeriodPicker
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

extension OnboardDetailsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedWeekday = Weekday.allCases[row]
        if pickerView == payFrequencyPicker {
            payFrequencyField.text = PaymentFrequency.allCases[row].title
            selectedPayFrequency = PaymentFrequency.allCases[row]
            
            firstDayViewHeightConstraint.constant = firstDayViewHeightHidden
            firstDayView.isHidden = true
            
            if (PaymentFrequency.allCases[row] == .biWeekly) {
                firstDayViewHeightConstraint.constant = firstDayViewHeightWithField
                firstDayView.isHidden = false
                firstDayDatePicker.isHidden = true
            }
//            frequencyValid = true
        } else if pickerView == statePicker {
            stateField.text = State.states[row].title
            selectedState = State.states[row]
            if let state = stateMinWages.data.first(where: { $0.state == State.states[row].title }),
               let minWage = state.minimumWage {
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

extension OnboardDetailsViewController {
    func validateInput() -> String? {
        
        var errorStr: String? = nil
            // Minimum Wage should be greater than 0
        if minimumWage.compare(NSNumber(0)) != .orderedDescending {
            errorStr = "err_enter_valid_minimum_wage".localized
        }
        
        return errorStr
    }
}

extension OnboardDetailsViewController {
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

extension OnboardDetailsViewController {
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        firstPayPeriod = selectedDate
        dateFormatter.dateFormat = "MMMM d, YYYY"
        firstPayPeriodField.text = dateFormatter.string(from: selectedDate)
        check()
        // Handle the value change here
        // You can access the selected date using the 'selectedDate' variable
        // Perform any desired actions or updates based on the new value
    }
}
