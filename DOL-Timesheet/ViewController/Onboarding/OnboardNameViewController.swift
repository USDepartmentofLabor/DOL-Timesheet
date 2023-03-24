//
//  OnboardNameViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardNameViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        canMoveForward = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userType == .employee {
            otherNameLabel.text = "What is your employer's name or nickname?"
        } else {
            otherNameLabel.text = "What is your employee's name or nickname?"
        }
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        self.workWeekStartPickerHeight.constant = 0
        
        nameLabel.text = NSLocalizedString("onboard_name", comment: "What is you name or nickname?")
        if userType == .employee {
            otherNameLabel.text = NSLocalizedString("onboard_name_employer", comment: "What is your employer's name or nickname?")
            nameNoteLabel.text = NSLocalizedString("onboard_employer_note", comment: "Note: you can add more employers later in Settings")
        } else {
            otherNameLabel.text = NSLocalizedString("onboard_name_employee", comment: "What is your employee's name or nickname?")
            nameNoteLabel.text = NSLocalizedString("onboard_employee_note", comment: "Note: You can add more employees later in Settings")
        }
        workweekLabel.text = NSLocalizedString("onboard_workweek_start", comment: "When does the workweek begin?")
        
        setupAccessibility()
        scrollView.keyboardDismissMode = .onDrag
        
        nameField.setBorderColor()
        otherNameField.setBorderColor()
        workweekField.setBorderColor()
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
        var errorStr: String? = nil
        
        let name = nameField.text
        if name == nil || name!.isEmpty {
            nameValid = false
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide User Name")
        }
        
        if let errorStr = errorStr {
            displayError(message: errorStr)
            return
        }
        nameValid = true
        check()
    }
    
    @IBAction func otherNameSet(_ sender: Any) {
        var errorStr: String? = nil
        
        let otherName = otherNameField.text
        if otherName == nil || otherName!.isEmpty {
            otherNameValid = false
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide Employer/Employee Name")
        }

        if let errorStr = errorStr {
            displayError(message: errorStr)
            return
        }
        otherNameValid = true
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
                workWeekStartPickerHeight.constant = 216
                otherNameSet(textField)
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

extension OnboardNameViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
}
