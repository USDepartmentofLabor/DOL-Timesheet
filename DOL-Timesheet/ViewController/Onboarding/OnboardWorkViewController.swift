//
//  OnboardWorkViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

enum ShownWorkPicker {
    case payPeriodPicker
    case workWeekStartPicker
    case none
}

class OnboardWorkViewController: OnboardBaseViewController {

    @IBOutlet weak var nameTitleLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var otherNameLabel: UILabel!
    @IBOutlet weak var otherNameField: UITextField!
    
    @IBOutlet weak var workweekLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var workweekField: UITextField!
    @IBOutlet weak var nameNoteLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var workWeekStartPicker: UIPickerView!
    @IBOutlet weak var workWeekStartPickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var firstDayPeriodText: UILabel!
    @IBOutlet weak var firstPayPeriodField: UITextField!
    
    @IBOutlet weak var firstDayDatePicker: UIDatePicker!
    @IBOutlet weak var firstDayPickerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: NavigationButton!
    
    var tapGesture: UITapGestureRecognizer?
    
//    weak var delegate: TimeViewControllerDelegate?
    var dateFormatter = {
        let formatter = DateFormatter()

        var locale = "en_EN"
        if (Localizer.currentLanguage == Localizer.SPANISH) {
            locale = "es_ES"
        }
        
        formatter.locale = Locale(identifier: locale)
        return formatter
    }()
    
    
    var pickerSelected = ShownWorkPicker.none
    
    var otherName: String?
    var nameValid: Bool = false
    var otherNameValid: Bool = false
    var workWeekStartValid: Bool = false
    var selectedWeekday: Weekday?
    var currentRow: Int = 0

    var firstPayPeriod: Date?
    
    let firstDayViewHeightWithPicker:CGFloat = 275
    let firstDayViewHeightWithField:CGFloat = 80
    let firstDayViewHeightHidden:CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        canMoveForward = false
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture!.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture!)
        
        setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let tapLocation = tapGesture!.location(in: scrollView)
        
        switch pickerSelected {
        case .payPeriodPicker:
            if firstDayDatePicker.frame.contains(tapLocation) {
                return
            }
            break
        default:
            break
        }
        workWeekStartPickerHeight.constant = 0
        setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    override func resetData() {
        canMoveForward = false
        
        nameValid = false
        otherNameValid = false
        workWeekStartValid = false
        selectedWeekday = nil
        currentRow = 0

        firstPayPeriod = nil
        
        if nameField != nil {
            nameField.text = nil
            otherNameField.text = nil
            workweekField.text = nil
            firstPayPeriodField.text = nil
        }
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        firstDayDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        if #available(iOS 14.0, *) {
            firstDayDatePicker.preferredDatePickerStyle = .inline
        } else {
            firstDayDatePicker.preferredDatePickerStyle = .wheels
        }
        setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
        self.workWeekStartPickerHeight.constant = 0
        workWeekStartPicker.selectRow(currentRow, inComponent: 0, animated: true)
        
        
        var locale = Locale(identifier: "en_EN")
        if (Localizer.currentLanguage == Localizer.SPANISH) {
            locale = Locale(identifier: "es_ES")
        }
        
        firstDayDatePicker.locale = locale
        firstDayDatePicker.calendar = locale.calendar
        firstDayDatePicker.calendar.firstWeekday = 1
        
        nameTitleLabel.text = "work".localized
        
        nameLabel.text = "onboard_name".localized
        if userType == .employer {
            otherNameLabel.text = "onboard_name_employee".localized
            nameNoteLabel.text = "onboard_employee_note".localized
            workweekLabel.text = "onboard_employee_workweek_start".localized
            firstDayPeriodText.text = "employee_first_pay_period".localized
        } else {
            otherNameLabel.text = "onboard_name_employer".localized
            nameNoteLabel.text = "onboard_employer_note".localized
            workweekLabel.text = "onboard_employer_workweek_start".localized
            firstDayPeriodText.text = "employer_first_pay_period".localized
        }
        
        setupAccessibility()
        scrollView.keyboardDismissMode = .onDrag
        
        nameField.setBorderColor()
        otherNameField.setBorderColor()
        workweekField.setBorderColor()
        firstPayPeriodField.setBorderColor()
    }
    
    func setupAccessibility() {
//        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }
    
    override func saveData() -> Bool  {
        print("OnboardWorkViewController SAVE DATA")
        
        check()
        if !canMoveForward {
            return false
        }
        
        let userName = nameField.text ?? ""
//        let userType = UserType(rawValue: employeeBtn.isSelected ? 0 : 1) ?? UserType.employee
        
        let currentUser = profileViewModel!.profileModel.currentUser
        currentUser?.name = userName
        
        if (employmentModel == nil) {
            guard let employmentModel = profileViewModel!.newTempEmploymentModel() else { return false}
            print("GGG Onboarding: OnboardWorkViewController-saveData created new Employement Model: \(employmentModel)")
            self.employmentModel = employmentModel
        }

        var user = employmentModel!.employmentUser
        if user == nil {
            user = employmentModel!.newEmploymentUser()
            print("GGG Onboarding: OnboardWorkViewController-saveData created new user: \(user.debugDescription)")
        }
        
        user?.name = otherNameField.text?.trimmingCharacters(in: .whitespaces)
        
        employmentModel!.workWeekStartDay = selectedWeekday ?? .sunday
        employmentModel?.employmentInfo.startDate = firstPayPeriod
        
        onboardingDelegate?.updateViewModels(
            profileViewModel: profileViewModel!,
            employmentModel: employmentModel!
        )
        return true
    }
    
    @IBAction func nameSet(_ sender: Any) {
        
        let name = nameField.text
        if name == nil || name!.isEmpty {
            nameValid = false
//            displayError(message: NSLocalizedString("err_enter_name", comment: "Please provide User Name"))
        } else {
            nameValid = true
        }
        
        check()
    }
    
    @IBAction func otherNameSet(_ sender: Any) {

        let otherName = otherNameField.text
        if otherName == nil || otherName!.isEmpty {
            otherNameValid = false
//            displayError(message: NSLocalizedString("err_enter_name", comment: "Please provide Employer/Employee Name"))
        } else {
            otherNameValid = true
        }
        check()
    }
    @IBAction func infoWorkweekPressed(_ sender: Any) {
        if userType == .employee {
            displayInfoPopup(sender, info: .employee_workweek)
        } else {
            displayInfoPopup(sender, info: .employer_workweek)
        }
    }
    
    func check() {
        if (nameValid && otherNameValid && workWeekStartValid && firstPayPeriod != nil ) {
            canMoveForward = true
        } else {
            canMoveForward = false
        }
        onboardingDelegate?.updateCanMoveForward(value: canMoveForward)
    }
    
    func setFirstDatePickerHeight(height: CGFloat, relatedBy: NSLayoutConstraint.Relation) {
        firstDayPickerHeightConstraint.constant = height
        

        // Create a new constraint with a greater than or equal to relation
        let newHeightConstraint = NSLayoutConstraint(item: firstDayPickerHeightConstraint.firstItem,
                                                      attribute: firstDayPickerHeightConstraint.firstAttribute,
                                                      relatedBy: relatedBy,
                                                      toItem: firstDayPickerHeightConstraint.secondItem,
                                                      attribute: firstDayPickerHeightConstraint.secondAttribute,
                                                      multiplier: firstDayPickerHeightConstraint.multiplier,
                                                      constant: firstDayPickerHeightConstraint.constant)

        firstDayPickerHeightConstraint.isActive = false
        newHeightConstraint.isActive = true

        // Optionally, update the IBOutlet reference
        firstDayPickerHeightConstraint = newHeightConstraint
        
    }
}

extension OnboardWorkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == otherNameField {
            if workweekField.text?.count == 0 {
                workweekField?.text = Weekday.sunday.title
            }
            workWeekStartValid = true
            check()
            textField.resignFirstResponder()
            workWeekStartPickerHeight.constant = 250
            otherNameSet(textField)
//            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: employeeEmployerView)
        }
        else {
            otherNameField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == workweekField {
            if workWeekStartPickerHeight.constant > 1 {
                workWeekStartPickerHeight.constant = 0
                pickerSelected = .none
            } else {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                workWeekStartPickerHeight.constant = 250
                workweekField.text = Weekday.allCases[currentRow].title
                selectedWeekday = Weekday.allCases[currentRow]
                workWeekStartValid = true
                check()
                otherNameSet(textField)
                setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
                pickerSelected = .workWeekStartPicker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.scrollView.scrollToBottom()
                }
            }
            return false
        } else if textField == firstPayPeriodField {
            if firstDayPickerHeightConstraint.constant > 1 {
                setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
                pickerSelected = .none
            } else {
                if firstPayPeriodField.text?.count == 0 {
                    firstPayPeriod = Date()
                    dateFormatter.dateFormat = "MMMM d, YYYY"
                    dateFormatter.locale = Locale(identifier: Localizer.currentLanguage)
                    let formattedDate = dateFormatter.string(from: firstPayPeriod!)
                    let formattedDateCapitalized = formattedDate.prefix(1).capitalized + formattedDate.dropFirst()
                    
                    firstPayPeriodField.text = formattedDateCapitalized

                }
                setFirstDatePickerHeight(height: 307, relatedBy: .greaterThanOrEqual)
                workWeekStartPickerHeight.constant = 0
                pickerSelected = .payPeriodPicker
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.scrollView.scrollToBottom()
                }
            }
            check()
            return false
        } else{
            workWeekStartPickerHeight.constant = 0
            setFirstDatePickerHeight(height: firstDayViewHeightHidden, relatedBy: .equal)
            pickerSelected = .none
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

extension OnboardWorkViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentRow = row
        workweekField.text = Weekday.allCases[row].title
        selectedWeekday = Weekday.allCases[row]
        workWeekStartValid = true
        check()
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Weekday.allCases[row].title
    }
}

extension OnboardWorkViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Weekday.allCases.count
    }
}
extension UIButton {
    func setBorderColor(named: String) {
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        if self.traitCollection.userInterfaceStyle == .dark {
            self.layer.borderColor = UIColor(named: named)?.cgColor
        } else {
            self.layer.borderColor = UIColor(named: named)?.cgColor
        }
        self.layer.borderWidth = 1.0
    }
}
extension UITextField {
    func setBorderColor() {
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        if self.traitCollection.userInterfaceStyle == .dark {
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.layer.borderColor = UIColor.lightGray.cgColor
        }
        self.layer.borderWidth = 1.0
    }
    
    func setErrorBorderColor() {
        self.layer.cornerRadius = 8.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1.0
    }
}

extension OnboardWorkViewController {
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        firstPayPeriod = selectedDate
        dateFormatter.dateFormat = "MMMM d, YYYY"
        dateFormatter.locale = Locale(identifier: Localizer.currentLanguage)
        let formattedDate = dateFormatter.string(from: firstPayPeriod!)
        let formattedDateCapitalized = formattedDate.prefix(1).capitalized + formattedDate.dropFirst()
        
        firstPayPeriodField.text = formattedDateCapitalized
        check()
        // Handle the value change here
        // You can access the selected date using the 'selectedDate' variable
        // Perform any desired actions or updates based on the new value
    }
}
