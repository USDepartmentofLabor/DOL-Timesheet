//
//  OnboardNameViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardNameViewController: OnboardBaseViewController {

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
    
    @IBOutlet weak var nextButton: NavigationButton!
    
//    weak var delegate: TimeViewControllerDelegate?
    
    var otherName: String?
    var nameValid: Bool = false
    var otherNameValid: Bool = false
    var workWeekStartValid: Bool = false
    var selectedWeekday: Weekday?
    var currentRow: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        canMoveForward = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        workWeekStartPickerHeight.constant = 0
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        self.workWeekStartPickerHeight.constant = 0
        workWeekStartPicker.selectRow(currentRow, inComponent: 0, animated: true)
        
        nameTitleLabel.text = "work".localized
        
        nameLabel.text = "onboard_name".localized
        if userType == .employee {
            otherNameLabel.text = "onboard_name_employer".localized
            nameNoteLabel.text = "onboard_employer_note".localized
        } else {
            otherNameLabel.text = "onboard_name_employee".localized
            nameNoteLabel.text = "onboard_employee_note".localized
        }
        workweekLabel.text = "onboard_workweek_start".localized
        
        setupAccessibility()
        scrollView.keyboardDismissMode = .onDrag
        
        nameField.setBorderColor()
        otherNameField.setBorderColor()
        workweekField.setBorderColor()
    }
    
    func setupAccessibility() {
//        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }
    
    override func saveData() -> Bool  {
        print("OnboardNameViewController SAVE DATA")
        
        check()
        if !canMoveForward {
            return false
        }
        
        let userName = nameField.text ?? ""
//        let userType = UserType(rawValue: employeeBtn.isSelected ? 0 : 1) ?? UserType.employee
        
        let currentUser = profileViewModel!.profileModel.newProfile(type: userType, name: userName)
        currentUser.name = userName
        
        if (employmentModel == nil) {
            guard let employmentModel = profileViewModel!.newTempEmploymentModel() else { return false}
            self.employmentModel = employmentModel
        }

        var user = employmentModel!.employmentUser
        if user == nil {
            user = employmentModel!.newEmploymentUser()
        }
//        user?.name = otherNameField.text?.trimmingCharacters(in: .whitespaces)
        
        user?.name = otherNameField.text?.trimmingCharacters(in: .whitespaces)
        
        employmentModel!.workWeekStartDay = selectedWeekday ?? .sunday
        
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
        if (nameValid && otherNameValid && workWeekStartValid) {
            canMoveForward = true
        } else {
            canMoveForward = false
        }
        onboardingDelegate?.updateCanMoveForward(value: canMoveForward)
    }
}

extension OnboardNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == otherNameField {
            if workweekField.text?.count == 0 {
                workweekField?.text = Weekday.sunday.title
            }
            workWeekStartValid = true
            check()
            textField.resignFirstResponder()
            workWeekStartPickerHeight.constant = 216
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
            } else {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                workWeekStartPickerHeight.constant = 216
                workweekField.text = Weekday.allCases[currentRow].title
                selectedWeekday = Weekday.allCases[currentRow]
                workWeekStartValid = true
                check()
                otherNameSet(textField)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.scrollView.scrollToBottom()
                }
            }
            return false
        } else {
            workWeekStartPickerHeight.constant = 0
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

extension OnboardNameViewController: UIPickerViewDelegate {
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

extension OnboardNameViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Weekday.allCases.count
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
