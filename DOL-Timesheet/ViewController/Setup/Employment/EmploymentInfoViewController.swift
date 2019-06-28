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
    @IBOutlet weak var nameTextField: UnderlinedTextField!
    @IBOutlet weak var street1TextField: UnderlinedTextField!
    @IBOutlet weak var street2TextField: UnderlinedTextField!
    @IBOutlet weak var cityTextField: UnderlinedTextField!
    @IBOutlet weak var stateTextField: UnderlinedTextField!
    @IBOutlet weak var zipcodeTextField: UnderlinedTextField!
    @IBOutlet weak var phoneTextField: UnderlinedTextField!
    @IBOutlet weak var emailTextField: UnderlinedTextField!
    
    
    @IBOutlet weak var employmentInfoView: UIView!
    
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var supervisorNameTextField: UnderlinedTextField!
    @IBOutlet weak var supervisorEmailTextField: UnderlinedTextField!
    @IBOutlet weak var employmentNumberTextField: UnderlinedTextField!
    @IBOutlet weak var startDateTextField: UnderlinedTextField!
    @IBOutlet weak var paymentTypeView: UIView!
    @IBOutlet weak var paymentTypeTextField: UnderlinedTextField!
    
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
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClicked(_:)))
        }
        
        employmentView.addBorder()
        employmentInfoView.addBorder()
        
        scrollView.keyboardDismissMode = .onDrag

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
        
        let nameTitle: String
        // If Employer
        if let viewModel = viewModel, viewModel.isProfileEmployer {
            title = NSLocalizedString("add_employee", comment: "Add Employee Title")
            titleInfoView.title = NSLocalizedString("employee_information", comment: "Employee Information")
            subTitleLabel.text = NSLocalizedString("who_works_for_you", comment: "Who works for you")
            userTitleLabel.text = NSLocalizedString("employee", comment: "Employee")
            nameTitle = NSLocalizedString("full_name", comment: "Full Name")
            titleInfoView.infoType = .employee
        }
        else {
            title = NSLocalizedString("add_employer", comment: "Add Employee Title")
            titleInfoView.title = NSLocalizedString("employer_information", comment: "Employer Information")
            subTitleLabel.text = NSLocalizedString("who_do_you_work_for", comment: "Who do you work for")
            userTitleLabel.text = NSLocalizedString("employer", comment: "Employer")
            nameTitle = NSLocalizedString("company_name", comment: "Company Name")
            titleInfoView.infoType = .employer
        }
        
        nameTitleLabel.text = "\(nameTitle)*"
        
        // remove Skip button from navbar
        if viewModel?.employmentUser != nil {
            isNewUser = false
            navigationItem.rightBarButtonItem = nil
            if let viewModel = viewModel, viewModel.isProfileEmployer {
                title = NSLocalizedString("edit_employee", comment: "Edit Employee Title")
            }
            else {
                title = NSLocalizedString("edit_employer", comment: "Edit Employee Title")
            }
        }
        else {
            paymentTypeView.removeFromSuperview()
        }
    }
    
    func displayInfo() {
        guard let viewModel = viewModel else { return }
        
        // If profile User is Employer, display Employee Information
        let user = viewModel.employmentUser
        
        nameTextField.text = user?.name
        street1TextField.text = user?.address?.street1
        street2TextField.text = user?.address?.street2
        cityTextField.text = user?.address?.city
        stateTextField.text = user?.address?.state
        zipcodeTextField.text = user?.address?.zipCode
        emailTextField.text = user?.email
        phoneTextField.text = user?.phone
        employmentNumberTextField.text = viewModel.employmentNumber
        supervisorNameTextField.text = viewModel.supervisorName
        supervisorEmailTextField.text = viewModel.supervisorEmail
        paymentTypeTextField.text = viewModel.paymentType.title
        startDate = viewModel.employmentStartDate
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
    
    deinit {
        print("EmploymentInfo Deinit")
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
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
        var errorStr: String? = nil
        
        let name = nameTextField.text
        if name == nil || name!.isEmpty {
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide name")
        }
        else if let zipcode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces),
            !zipcode.isEmpty, !Util.isValidPostalCode(postalCode: zipcode) {
            errorStr = NSLocalizedString("err_invalid_zipcode", comment: "Please provide valid zipcode")
        }
        else if let emailAddress = emailTextField.text?.trimmingCharacters(in: .whitespaces),
            !emailAddress.isEmpty, !Util.isValidEmailAddress(emailAddress: emailAddress) {
            errorStr = NSLocalizedString("err_invalid_emailaddress", comment: "Please provide valid email")
        }
        else if let supervisorEmailAddress = supervisorEmailTextField.text?.trimmingCharacters(in: .whitespaces),
            !supervisorEmailAddress.isEmpty, !Util.isValidEmailAddress(emailAddress: supervisorEmailAddress) {
            errorStr = NSLocalizedString("err_invalid_supervisor_emailaddress", comment: "Please provide valid supervisor email")
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
        let street1 = street1TextField.text?.trimmingCharacters(in: .whitespaces)
        let street2 = street2TextField.text?.trimmingCharacters(in: .whitespaces)
        let city = cityTextField.text?.trimmingCharacters(in: .whitespaces)
        let state = stateTextField.text?.trimmingCharacters(in: .whitespaces)
        let zipCode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces)
        user?.setAddress(street1: street1, street2: street2, city: city, state: state, zipCode: zipCode)
        
        user?.phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces)
        user?.email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
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
        if textField == employmentNumberTextField {
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
            }
            
            showPopup(popupController: optionsVC, sender: textField)
        }
        else if textField == paymentTypeTextField {
            
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
            }
            
            showPopup(popupController: optionsVC, sender: textField)
        }
        else if textField == startDateTextField {
            
            DispatchQueue.main.async { [weak self] in
                self?.view.endEditing(true)
            }
            
            let timePickerVC = TimePickerViewController.instantiateFromStoryboard()
            timePickerVC.delegate = self
            timePickerVC.sourceView = startDateTextField
            timePickerVC.pickerMode = .date
            
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
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        startDate = datePicker.date
    }
}


extension EmploymentInfoViewController {
    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        if let timePicketVC = popoverPresentationController.presentedViewController as? TimePickerViewController {
            timePicketVC.delegate?.timeChanged(sourceView: timePicketVC.sourceView, datePicker: timePicketVC.datePicker)
        }
    }
}
