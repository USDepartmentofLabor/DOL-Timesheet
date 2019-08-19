//
//  SetupProfileViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import AVKit

class SetupProfileViewController: UIViewController {
    
    var isWizard: Bool = false
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var profileSubTitleLabel: UILabel!

    @IBOutlet weak var myProfileView: UIView!
    
    @IBOutlet weak var myProfileTitleLabel: UILabel!
    
    
    @IBOutlet weak var employeeEmployerView: UIView!
    @IBOutlet weak var employeeEmployerInfoView: LabelInfoView!
    
    @IBOutlet weak var employeeBtn: RadioButton!
    @IBOutlet weak var employerBtn: RadioButton!
    
    
    @IBOutlet weak var nameTitleLabel: TitleValueLabel!
    @IBOutlet weak var addressTitleLabel: TitleValueLabel!
    @IBOutlet weak var cityTitleLabel: TitleValueLabel!
    @IBOutlet weak var stateTitleLabel: TitleValueLabel!
    @IBOutlet weak var zipCodeTitleLabel: TitleValueLabel!
    @IBOutlet weak var phoneTitleLabel: TitleValueLabel!
    @IBOutlet weak var emailTitleLabel: TitleValueLabel!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UnderlinedTextField!
    @IBOutlet weak var street1TextField: UnderlinedTextField!
    @IBOutlet weak var street2TextField: UnderlinedTextField!
    @IBOutlet weak var cityTextField: UnderlinedTextField!
    @IBOutlet weak var stateTextField: UnderlinedTextField!
    @IBOutlet weak var zipcodeTextField: UnderlinedTextField!
    @IBOutlet weak var phoneTextField: UnderlinedTextField!
    @IBOutlet weak var emailTextField: UnderlinedTextField!
    
    @IBOutlet weak var manageEmploymentContentView: UIView!
    
    @IBOutlet weak var footerView: UIView!
    weak var delegate: TimesheetViewControllerDelegate?
    
    weak var manageVC: ManageUsersViewController?
    
    lazy var viewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    var profileImage: UIImage? {
        didSet {
//            profileImageView.image = profileImage
            if let profileImage = profileImage {
                profileImageView.maskCircle(anyImage: profileImage)
            }
        }
    }
    
    var profileType = UserType.employee {
        didSet {
            if profileType == .employee {
                employeeBtn.isSelected = true
                employerBtn.isSelected = false
                addressTitleLabel.text = NSLocalizedString("home_address", comment: "Work Address")
            }
            else {
                employeeBtn.isSelected = false
                employerBtn.isSelected = true
                addressTitleLabel.text = NSLocalizedString("work_address", comment: "Work Address")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        navigationItem.hidesBackButton = true
        title = "My Profile"
        
        myProfileView.addBorder()
        employeeEmployerInfoView.delegate = self
        
        profileImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editPhoto(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        profileTitleLabel.scaleFont(forDataType: .questionTitle)
        profileSubTitleLabel.scaleFont(forDataType: .subTitle)
        myProfileTitleLabel.scaleFont(forDataType: .sectionTitle)
        myProfileView.addBorder()
        employeeEmployerView.addBorder()
        
        nameTextField.delegate = self
        street1TextField.delegate = self
        street2TextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipcodeTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        
        scrollView.keyboardDismissMode = .onDrag
        setupAccessibility()
        
        displayInfo()
    }
    
    func setupAccessibility() {
        var titleLabel = NSLocalizedString("full_name", comment: "")
        nameTextField.accessibilityLabel = titleLabel

        titleLabel.append(" ")
        titleLabel.append(NSLocalizedString("required", comment: "Required"))
        nameTitleLabel.accessibilityLabel =  titleLabel
        street1TextField.accessibilityLabel = NSLocalizedString("street1", comment: "Stree1")
        street2TextField.accessibilityLabel = NSLocalizedString("street2", comment: "Stree2")
        cityTextField.accessibilityLabel = cityTitleLabel.text
        stateTextField.accessibilityLabel = stateTitleLabel.text
        zipcodeTextField.accessibilityLabel = zipCodeTitleLabel.text
        phoneTextField.accessibilityLabel = phoneTitleLabel.text
        emailTextField.accessibilityLabel = emailTitleLabel.text
        
        stateTextField.accessibilityTraits = [.button, .staticText]
        stateTextField.accessibilityHint = NSLocalizedString("state_hint", comment: "Tap to Select State")
        
        profileImageView.accessibilityHint = NSLocalizedString("profile_image_new_hint", comment: "Tap to select profile photo")
    }
    
    func displayInfo() {
        guard let profileUser = viewModel.profileModel.currentUser else {
            manageEmploymentContentView.removeFromSuperview()
            
            profileType = .employee
            isWizard = true
            return
        }
        
        headerView.removeFromSuperview()
        footerView.removeFromSuperview()
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClicked(_:)))
        navigationItem.leftBarButtonItem = cancelBtn
        
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveClicked(_:)))
        navigationItem.rightBarButtonItem = saveBtn
        
        nameTextField.text = profileUser.name
        street1TextField.text = profileUser.address?.street1
        street2TextField.text = profileUser.address?.street2
        cityTextField.text = profileUser.address?.city
        stateTextField.text = profileUser.address?.state
        zipcodeTextField.text = profileUser.address?.zipCode
        phoneTextField.text = profileUser.phone
        emailTextField.text = profileUser.email
        profileImageView.maskCircle(anyImage: profileUser.image?.normalizedImage() ?? #imageLiteral(resourceName: "Default Profile Photo"))
        profileImageView.accessibilityHint = (profileUser.image == nil) ?
            NSLocalizedString("profile_image_new_hint", comment: "Tap to select profile photo") :
            NSLocalizedString("profile_image_hint", comment: "Tap to update profile photo")
        
        zipcodeTextField.attributedPlaceholder = NSAttributedString(string: "XXXXX / XXXXX-XXXX", attributes:
            [NSAttributedString.Key.foregroundColor:  UIColor.borderColor,
             NSAttributedString.Key.font: Style.scaledFont(forDataType: .nameValueText)])
        profileType = viewModel.profileModel.isEmployer ? .employer : .employee
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
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 15, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addEmploymentInfo",
            let employmentVC = segue.destination as? EmploymentInfoViewController {
            employmentVC.viewModel = viewModel.newTempEmploymentModel()
            employmentVC.viewModel?.isWizard = isWizard
            employmentVC.delegate = delegate
        }
        else if segue.identifier == "editEmploymentInfo",
            let employmentVC = segue.destination as? EmploymentInfoViewController,
            let employmentModel = sender as? EmploymentModel {
            employmentVC.viewModel = employmentModel
            employmentVC.delegate = delegate
        }
        else if let destVC = segue.destination as? ManageUsersViewController {
//            destVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
            destVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext)
            destVC.view.translatesAutoresizingMaskIntoConstraints = false
            destVC.isEmbeded = true
            destVC.delegate = delegate
            manageVC = destVC
        }
    }
    
    @objc private func editPhoto(_ sender: UITapGestureRecognizer) {
        struct Option: OptionsProtocol {
            let title: String
        }
        let options: [Option] = [Option(title: "Camera"), Option(title:"Photo Library")]
        let optionsVC = OptionsListViewController(options: options,
                                                  title: "")
        optionsVC.didSelect = { [weak self] (popVC: UIViewController, option: Option?) in
            guard let strongSelf = self else { return }
            popVC.dismiss(animated: true, completion: nil)
            if let option = option {
                option.title == "Camera" ? strongSelf.camera() : strongSelf.photoLibrary()
            }
        }
        
        showPopup(popupController: optionsVC, sender: profileImageView)
    }
    
    @IBAction func employeeBtnClick(_ sender: Any) {
        // Profile is Employer, check if there are any Employees for this user
        if let employer = viewModel.profileModel.currentUser as? Employer {
            changeToEmployee(employer: employer)
        }
        else {
            profileType = .employee
        }

    }
    
    fileprivate func changeToEmployee(employer: Employer) {
        if (employer.employees?.count ?? 0) > 0 {
            let alertController =
                UIAlertController(title: NSLocalizedString("confirm_title", comment: "Confirm"),
                                  message: NSLocalizedString("confirm_delete_employees",
                                                             comment: "Delete Employees?"),
                                  preferredStyle: .alert)
            
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel))
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: .destructive) { _ in
                    self.toggleUserType()
                }
            )
            present(alertController, animated: true)
        }
        else {
            toggleUserType()
        }
    }
    
    func toggleUserType() {
        if let employer = viewModel.profileModel.currentUser as? Employer {
            viewModel.changeToEmployee(employer: employer)
            profileType = .employee
        }
        else if let employee = viewModel.profileModel.currentUser as? Employee {
            viewModel.changeToEmployer(employee: employee)
            profileType = .employer
        }
        
        manageVC?.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
    }
    
    
    @IBAction func employerBtnClick(_ sender: Any) {
        if let employee = viewModel.profileModel.currentUser as? Employee {
            changeToEmployer(employee: employee)
        }
        else {
            profileType = .employer
        }
    }
    
    fileprivate func changeToEmployer(employee: Employee) {
        if (employee.employers?.count ?? 0) > 0 {
            let alertController =
                UIAlertController(title: NSLocalizedString("confirm_title", comment: "Confirm"),
                                  message: NSLocalizedString("confirm_delete_employers",
                                                             comment: "Confirm Delete Employers"),
                                  preferredStyle: .alert)
            
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel))
            alertController.addAction(
                UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: .destructive) { _ in
                    self.toggleUserType()
                }
            )
            present(alertController, animated: true)
        }
        else {
            toggleUserType()
        }
    }

    
    @IBAction func nextClick(_ sender: Any) {
        guard validateInput() == true else {
            return
        }
        
        let userName = nameTextField.text ?? ""
        let userType = UserType(rawValue: employeeBtn.isSelected ? 0 : 1) ?? UserType.employee

        _ = viewModel.profileModel.newProfile(type: userType, name: userName)

        saveProfile()
        performSegue(withIdentifier: "addEmploymentInfo", sender: self)
    }
    
    @objc func cancelClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveClicked(_ sender: Any) {
        if !validateInput() {
            return
        }
        
        saveProfile()
        delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }

    func addClicked() {
        if !validateInput() {
            return
        }
        
        updateProfile()
        performSegue(withIdentifier: "addEmploymentInfo", sender: self)
    }
    
    func editClicked(viewModel: EmploymentModel) {
        if !validateInput() {
            return
        }
        
        updateProfile()
        performSegue(withIdentifier: "editEmploymentInfo", sender: viewModel)
    }
    
    func saveProfile() {
        updateProfile()
        viewModel.saveProfile()
    }
    
    func updateProfile() {
        guard let  profileUser = viewModel.profileModel.currentUser else {
            return
        }
        
        profileUser.name = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        let street1 = street1TextField.text?.trimmingCharacters(in: .whitespaces)
        let street2 = street2TextField.text?.trimmingCharacters(in: .whitespaces)
        let city = cityTextField.text?.trimmingCharacters(in: .whitespaces)
        let state = stateTextField.text?.trimmingCharacters(in: .whitespaces)
        let zipcode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces)
        profileUser.setAddress(street1: street1, street2: street2, city: city, state: state, zipCode: zipcode)
        
        profileUser.phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces)
        profileUser.email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        if let profileImage = profileImage?.normalizedImage() {
            profileUser.image = profileImage
        }
    }
    
    func validateInput() -> Bool {
        let name = nameTextField.text
        
        var errorStr: String? = nil
        if name == nil || name!.isEmpty {
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide name")
        }
        else if let zipcode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces),
            !zipcode.isEmpty, !Util.isValidPostalCode(postalCode: zipcode) {
            errorStr = NSLocalizedString("err_invalid_zipcode", comment: "Please provide valid zipcode")
        }
        else if let phoneNumber = phoneTextField.text?.trimmingCharacters(in: .whitespaces),
            !phoneNumber.isEmpty, !Util.isValidPhoneNumber(phoneNumber: phoneNumber) {
            errorStr = NSLocalizedString("err_invalid_phonenumber", comment: "Please provide valid phoneNumber")
        }
        else if let emailAddress = emailTextField.text?.trimmingCharacters(in: .whitespaces),
            !emailAddress.isEmpty, !Util.isValidEmailAddress(emailAddress: emailAddress) {
            errorStr = NSLocalizedString("err_invalid_emailaddress", comment: "Please provide valid email")
        }
        
        if let errorStr = errorStr {
            displayError(message: errorStr)
            return false
        }
        
        return true
    }
    
    func addManageEmploymentView() {
        let controller = ManageUsersViewController.instantiateFromStoryboard("Profile")
        addChild(controller)
        controller.viewModel = viewModel
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        manageEmploymentContentView.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: manageEmploymentContentView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: manageEmploymentContentView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: manageEmploymentContentView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: manageEmploymentContentView.bottomAnchor)
            ])
        
        controller.didMove(toParent: self)
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
    }
}

extension SetupProfileViewController {
    fileprivate func camera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }

        checkCameraAccess()
    }
    
    fileprivate func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            takeCameraPicture()
        case .denied:
            takeCameraPermission()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    self.takeCameraPicture()
                }
            }
        case .restricted:
            print("Access Restricted")
        @unknown default:
            print("Unknown Error")
        }
    }
    
    func takeCameraPermission() {
        let title = NSLocalizedString("err_camera_denied_title", comment: "Camera access is denied")
        let alertController = UIAlertController(title: title,
                                                message: NSLocalizedString("err_camera_denied", comment: "Camera access is denied"),
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel))
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("settings", comment: "Settings"), style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }

    func takeCameraPicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self;
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}

extension SetupProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfEmploymentInfo
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as! ProfileTableViewCell
        
        let employmentModels = viewModel.employmentModels
        if indexPath.row < employmentModels.count {
            let employmentModel = employmentModels[indexPath.row]
            if viewModel.isProfileEmployer {
                cell.nameLabel.text = employmentModel.employeeName
                cell.addressLabel.text = employmentModel.employeeAddress?.description
            }
            else {
                cell.nameLabel.text = employmentModel.employerName
                cell.addressLabel.text = employmentModel.employerAddress?.description
            }
            
            cell.paymentLabel.text = employmentModel.paymentTypeTitle
        }
        
        return cell
    }
}

extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let attachImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage = attachImage
        }
        
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nameTitleLabel)
    }
}

extension SetupProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
        }
        else {
            let nextTextField = view.viewWithTag(textField.tag + 1)
            nextTextField?.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == stateTextField {
            
            let announcementMsg = NSLocalizedString("select_state", comment: "Select State")
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
}
