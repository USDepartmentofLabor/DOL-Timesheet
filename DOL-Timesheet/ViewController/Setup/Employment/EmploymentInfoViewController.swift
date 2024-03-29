//
//  EmploymentInfoViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/16/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class EmploymentInfoViewController: SetupBaseEmploymentViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var employmentView: UIView!
    
    @IBOutlet weak var titleInfoView: LabelInfoView!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var userTitleLabel: UILabel!
    
    @IBOutlet weak var nameTitleLabel: TitleValueLabel!
    @IBOutlet weak var cityTitleLabel: TitleValueLabel!
    @IBOutlet weak var stateTitleLabel: TitleValueLabel!
    @IBOutlet weak var zipCodeTitleLabel: TitleValueLabel!
    @IBOutlet weak var phoneTitleLabel: TitleValueLabel!
    @IBOutlet weak var emailTitleLabel: TitleValueLabel!

    @IBOutlet weak var nameTextField: UnderlinedTextField!
    @IBOutlet weak var street1TextField: UnderlinedTextField!
    @IBOutlet weak var street2TextField: UnderlinedTextField!
    @IBOutlet weak var cityTextField: UnderlinedTextField!
    @IBOutlet weak var stateTextField: UnderlinedTextField!
    @IBOutlet weak var zipcodeTextField: UnderlinedTextField!
    @IBOutlet weak var phoneTextField: UnderlinedTextField!
    @IBOutlet weak var emailTextField: UnderlinedTextField!
    
    @IBOutlet weak var addressLine1View: UIView!
    @IBOutlet weak var addressLine2View: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var zipCodeView: UIView!
    
    @IBOutlet weak var requiredFooterLabel: UILabel!
    
    @IBOutlet weak var employmentInfoView: UIView!
    
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var addressTitleLabel: TitleValueLabel!
    
    @IBOutlet weak var supervisorNameTitleLabel: TitleValueLabel!
    @IBOutlet weak var supervisorEmailTitleLabel: TitleValueLabel!
    @IBOutlet weak var employeeNumberTitleLabel: TitleValueLabel!
    @IBOutlet weak var startDateTitleLabel: TitleValueLabel!
    @IBOutlet weak var paymentTypeTitleLabel: TitleValueLabel!

    @IBOutlet weak var supervisorNameTextField: UnderlinedTextField!
    @IBOutlet weak var supervisorEmailTextField: UnderlinedTextField!
    @IBOutlet weak var employmentNumberTextField: UnderlinedTextField!
    @IBOutlet weak var startDateTextField: UnderlinedTextField!
    @IBOutlet weak var paymentTypeView: UIView!
    @IBOutlet weak var paymentTypeTextField: UnderlinedTextField!
    
    @IBOutlet weak var nextBtn: NavigationButton!
    var timePickerVC: TimePickerViewController?

    
    var activeField: UIView?
    var startDate: Date = Date() {
        didSet {
            startDateTextField.text = startDate.formattedDate
        }
    }

    var isNewUser: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupView() {
        super.setupView()

        assert(viewModel != nil)
        
        // If this is Root ViewController
        if let rootViewController = navigationController?.viewControllers.first,
            rootViewController == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "cancel".localized,
                style: .plain,
                target: self,
                action: #selector(cancelClicked(_:)))
        }
        
        employmentView.addBorder()
        employmentInfoView.addBorder()
        
        scrollView.keyboardDismissMode = .onDrag

        zipcodeTextField.attributedPlaceholder = NSAttributedString(string: "99999 or 99999-9999", attributes:
            [NSAttributedString.Key.foregroundColor:  UIColor.borderColor,
             NSAttributedString.Key.font: Style.scaledFont(forDataType: .nameValueText)])

        titleInfoView.delegate = self
        subTitleLabel.scaleFont(forDataType: .subTitle)
        nameTextField.delegate = self
        street1TextField.delegate = self
        street2TextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipcodeTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        supervisorNameTextField.delegate = self
        supervisorEmailTextField.delegate = self
        employmentNumberTextField.delegate = self
        paymentTypeTextField.delegate = self
        startDateTextField.delegate = self
        
        userTitleLabel.scaleFont(forDataType: .sectionTitle)
        employmentTitleLabel.scaleFont(forDataType: .sectionTitle)
        
        setupEmploymentType(isProfileEmployer: viewModel?.isProfileEmployer ?? false)
        
        requiredFooterLabel.text = "indicates_a_required_field".localized
        
        cityTitleLabel.text = "city".localized
        stateTitleLabel.text = "state".localized
        zipCodeTitleLabel.text = "zip_code".localized
        zipcodeTextField.placeholder = "zipcode_hint".localized
        phoneTitleLabel.text = "phone".localized
        emailTitleLabel.text = "email".localized
        
        employmentTitleLabel.text = "employment".localized
        supervisorNameTitleLabel.text = "supervisor_name".localized
        supervisorEmailTitleLabel.text = "supervisor_email".localized
        employeeNumberTitleLabel.text = "employee_number".localized
        startDateTitleLabel.text = "start_date".localized
        
        nextBtn.setTitle("next".localized, for: .normal)
        
        // remove Skip button from navbar
        if viewModel?.employmentUser != nil {
            isNewUser = false
            navigationItem.rightBarButtonItem = nil
            if let viewModel = viewModel, viewModel.isProfileEmployer {
                title = "edit_employee".localized
            }
            else {
                title = "edit_employer".localized
            }
        }
        else {
            paymentTypeView.removeFromSuperview()
        }
        
        requiredFooterLabel.scaleFont(forDataType: .footerText)
        setupAccessibility()
    }
    
    func setupEmploymentType(isProfileEmployer: Bool) {
        let nameTitle: String
        let addressTitle: String
        
        var tag = nameTextField.tag
        // If Employer
        if isProfileEmployer {
            title = "add_employee".localized
            titleInfoView.title = "employee_information".localized
            subTitleLabel.text = "who_works_for_you".localized
            userTitleLabel.text = "employee".localized
            nameTitle = "full_name".localized
            titleInfoView.infoType = .employee
            addressTitle = "home_address".localized
            addressLine1View.isHidden = true
            addressLine2View.isHidden = true
            cityView.isHidden = true
            stateView.isHidden = true
            zipCodeView.isHidden = true
            
            street1TextField.tag = 0
            street2TextField.tag = 0
            cityTextField.tag = 0
            stateTextField.tag = 0
            zipcodeTextField.tag = 0

        }
        else {
            title = "add_employer".localized
            titleInfoView.title = "employer_information".localized
            subTitleLabel.text = "who_do_you_work_for".localized
            userTitleLabel.text = "employer".localized
            nameTitle = "company_name".localized
            titleInfoView.infoType = .employer
            addressTitle = "work_address".localized
            
            street1TextField.tag = tag+1
            street2TextField.tag = tag+2
            cityTextField.tag = tag+3
            stateTextField.tag = tag+4
            zipcodeTextField.tag = tag+5
            tag = tag+5
        }
        
        nameTitleLabel.text = "\(nameTitle)*"
        nameTitleLabel.accessibilityLabel = "\(nameTitle) Required"
        nameTextField.accessibilityLabel = nameTitle
        addressTitleLabel.text = addressTitle
        
        phoneTextField.tag = tag+1
        emailTextField.tag = tag+2
        supervisorNameTextField.tag = tag+3
        supervisorEmailTextField.tag = tag+4
        employmentNumberTextField.tag = tag+5
        startDateTextField.tag = tag+6
    }
    
    func setupAccessibility() {
        nameTextField.accessibilityLabel =  nameTitleLabel.accessibilityLabel
        street1TextField.accessibilityLabel = "street1".localized
        street2TextField.accessibilityLabel = "street2".localized
        cityTextField.accessibilityLabel = cityTitleLabel.text
        stateTextField.accessibilityLabel = stateTitleLabel.text
        zipcodeTextField.accessibilityLabel = zipCodeTitleLabel.text
        phoneTextField.accessibilityLabel = phoneTitleLabel.text
        emailTextField.accessibilityLabel = emailTitleLabel.text
        
        stateTextField.accessibilityTraits = [.button, .staticText]
        stateTextField.accessibilityHint = "state_hint".localized
        
        supervisorNameTextField.accessibilityLabel = supervisorNameTitleLabel.text
        supervisorEmailTextField.accessibilityLabel = supervisorEmailTitleLabel.text
        startDateTextField.accessibilityLabel = startDateTitleLabel.text
        paymentTypeTextField.accessibilityLabel = paymentTypeTitleLabel.text
        employmentNumberTextField.accessibilityLabel = employeeNumberTitleLabel.text
        
        startDateTextField.accessibilityTraits = [.button, .staticText]
        startDateTextField.accessibilityHint = "start_date_hint".localized

        paymentTypeTextField.accessibilityTraits = [.button, .staticText]
        paymentTypeTextField.accessibilityHint = "payment_type_hint".localized

        if Util.isVoiceOverRunning {
            requiredFooterLabel.isHidden = true
        }
        else {
            requiredFooterLabel.isHidden = false
        }
    }

    func displayInfo() {
        guard let viewModel = viewModel else { return }
        
        // If profile User is Employer, display Employee Information
        let user = viewModel.employmentUser
        
        nameTextField.text = user?.name
        
        if !viewModel.isProfileEmployer {
            street1TextField.text = user?.address?.street1
            street2TextField.text = user?.address?.street2
            cityTextField.text = user?.address?.city
            stateTextField.text = user?.address?.state
            zipcodeTextField.text = user?.address?.zipCode
        }
        
        emailTextField.text = user?.email
        phoneTextField.text = user?.phone
        employmentNumberTextField.text = viewModel.employmentNumber
        supervisorNameTextField.text = viewModel.supervisorName
        supervisorEmailTextField.text = viewModel.supervisorEmail
        paymentTypeTextField.text = viewModel.paymentType.title
        startDate = viewModel.employmentStartDate
        nameTextField.placeholder = "required".localized
        paymentTypeTitleLabel.text = "payment_type".localized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "editEmploymentInfo",
            let destVC = segue.destination as? EditEmploymentInfoViewController {
            destVC.viewModel = viewModel
            destVC.delegate = delegate
        }
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 15, right: 0)

        if let activeField = activeField {
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            let aRect = activeField.convert(activeField.frame, to: scrollView)
            scrollView.scrollRectToVisible(aRect, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @IBAction func nextClick(_ sender: Any) {
        guard validateInput() else { return }
        
        updateEmployment()
    }
    
    func validateInput() -> Bool {
        guard let viewModel = viewModel else { return false }
        
        var errorStr: String? = nil
        
        let name = nameTextField.text
        if name == nil || name!.isEmpty {
            errorStr = "err_enter_name".localized
        }
        else if !viewModel.isProfileEmployer,
            let zipcode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces),
            !zipcode.isEmpty, !Util.isValidPostalCode(postalCode: zipcode) {
            errorStr = "err_invalid_zipcode".localized
        }
        else if let phoneNumber = phoneTextField.text?.trimmingCharacters(in: .whitespaces),
            !phoneNumber.isEmpty, !Util.isValidPhoneNumber(phoneNumber: phoneNumber) {
            errorStr = "err_invalid_phonenumber".localized
        }
        else if let emailAddress = emailTextField.text?.trimmingCharacters(in: .whitespaces),
            !emailAddress.isEmpty, !Util.isValidEmailAddress(emailAddress: emailAddress) {
            if viewModel.isProfileEmployer {
                errorStr = "err_invalid_employee_emailaddress".localized
            }
            else {
                errorStr = "err_invalid_employer_emailaddress".localized
            }
        }
        else if let supervisorEmailAddress = supervisorEmailTextField.text?.trimmingCharacters(in: .whitespaces),
            !supervisorEmailAddress.isEmpty, !Util.isValidEmailAddress(emailAddress: supervisorEmailAddress) {
            errorStr = "err_invalid_supervisor_emailaddress".localized
        }

        if let errorStr = errorStr {
            displayError(message: errorStr)
            return false
        }
        
        return true

    }
    
    func updateEmployment() {
        guard let viewModel = viewModel else { return }
        
        viewModel.employmentNumber = employmentNumberTextField.text?.trimmingCharacters(in: .whitespaces)
        viewModel.supervisorName = supervisorNameTextField.text?.trimmingCharacters(in: .whitespaces)
        viewModel.supervisorEmail = supervisorEmailTextField.text?.trimmingCharacters(in: .whitespaces)
        viewModel.employmentStartDate = startDate

        var user = viewModel.employmentUser
        if user == nil {
            user = viewModel.newEmploymentUser()
        }
        
        user?.name = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        if !viewModel.isProfileEmployer {
            let street1 = street1TextField.text?.trimmingCharacters(in: .whitespaces)
            let street2 = street2TextField.text?.trimmingCharacters(in: .whitespaces)
            let city = cityTextField.text?.trimmingCharacters(in: .whitespaces)
            let state = stateTextField.text?.trimmingCharacters(in: .whitespaces)
            let zipCode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces)
            user?.setAddress(street1: street1, street2: street2, city: city, state: state, zipCode: zipCode)
        }
        
        user?.phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces)
        user?.email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
        let backItem = UIBarButtonItem()
        backItem.title = "back".localized
        navigationItem.backBarButtonItem = backItem
        
        if isNewUser {
            performSegue(withIdentifier: "setupPaymentFrequency", sender: self)
        }
        else {
           performSegue(withIdentifier: "editEmploymentInfo", sender: self)
        }
    }
}


extension EmploymentInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        else {
            let nextTextField = view.viewWithTag(textField.tag + 1)
            nextTextField?.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        var point = textField.convert(textField.frame.origin, to: scrollView)
//        point.x = 0.0 //if your textField does not have an origin at 0 for x and you don't want your scrollView to shift left and right but rather just up and down
//        scrollView.setContentOffset(point, animated: true)

//        let aRect = textField.convert(textField.frame, to: scrollView)
//        scrollView.scrollRectToVisible(aRect, animated: true)
        if textField == stateTextField {
            let announcementMsg = "select_state".localized
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementMsg)

            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(true)
            }
            
            let optionsVC = OptionsListViewController(options: State.states, title: "States")
            optionsVC.didSelect = { [weak self] (popVC: UIViewController, state: State?) in
                guard let strongSelf = self else { return }
                if let state = state {
                    strongSelf.stateTextField.text = state.title
                }
                optionsVC.dismiss(animated: true, completion: nil)
               
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: strongSelf.zipcodeTextField)
            }
            
            showPopup(popupController: optionsVC, sender: textField)
        }
        else if textField == paymentTypeTextField {
            let announcementMsg = "select_payment_type".localized
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementMsg)

            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(true)
            }
            
            let optionsVC = OptionsListViewController(options: PaymentType.allCases, title: "")
            optionsVC.didSelect = { [weak self] (popVC: UIViewController, paymentType: PaymentType?) in
                guard let strongSelf = self else { return }
                if let paymentType = paymentType {
                    strongSelf.paymentTypeTextField.text = paymentType.title
                    strongSelf.viewModel?.paymentType = paymentType
                }
                optionsVC.dismiss(animated: true, completion: nil)
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: strongSelf.nextBtn)
            }
            
            showPopup(popupController: optionsVC, sender: textField)
        }
        else if textField == startDateTextField {
            let announcementMsg = "select_start_date".localized
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementMsg)

            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(true)
            }
            
            let timePickerVC = TimePickerViewController.instantiateFromStoryboard()
            timePickerVC.delegate = self
            timePickerVC.sourceView = startDateTextField
            timePickerVC.pickerMode = .date
            
            self.timePickerVC = timePickerVC
            showPopup(popupController: timePickerVC, sender: startDateTextField)
        }
        else {
            activeField = textField
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneTextField {
            var fullString = textField.text ?? ""
            fullString.append(string)
            if range.length == 1 {
                textField.text = PhoneFormatter.format(phoneNumber: fullString, shouldRemoveLastDigit: true)
            } else {
                textField.text = PhoneFormatter.format(phoneNumber: fullString)
            }
            
            return false
        }
        
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
}

extension EmploymentInfoViewController: TimePickerProtocol {
    func donePressed() {
        guard let pickerVC = self.timePickerVC else { return }
        timeChanged(sourceView: pickerVC.sourceView, datePicker: pickerVC.datePicker)
        self.dismiss(animated: true, completion: nil)
    }
    
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        startDate = datePicker.date
        
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: startDateTextField)
    }
}


extension EmploymentInfoViewController {
    public override func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        super.popoverPresentationControllerDidDismissPopover(popoverPresentationController)
        if let timePicketVC = popoverPresentationController.presentedViewController as? TimePickerViewController {
            timePicketVC.delegate?.timeChanged(sourceView: timePicketVC.sourceView, datePicker: timePicketVC.datePicker)
        }
    }
}
