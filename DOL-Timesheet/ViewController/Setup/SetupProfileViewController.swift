//
//  SetupProfileViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import AVKit
import MessageUI

class SetupProfileViewController: UIViewController {
    let updatedDBVersion = "UpdatedDBVersion"

    var isWizard: Bool = false
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var profileTitleLabel: UILabel!
    @IBOutlet weak var profileSubTitleLabel: UILabel!

    @IBOutlet weak var myProfileView: UIView!
    
    @IBOutlet weak var myProfileTitleLabel: UILabel!
    
    @IBOutlet weak var requiredFooterLabel: UILabel!
    
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
    
    @IBOutlet weak var addressLine1View: UIView!
    @IBOutlet weak var addressLine2View: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var zipCodeView: UIView!

    @IBOutlet weak var manageEmploymentContentView: UIView!
    
    @IBOutlet weak var footerView: UIView!
    weak var delegate: TimeViewControllerDelegate?
    
    @IBOutlet weak var nextBtn: NavigationButton!
    
    @IBOutlet weak var holaHelloButton: UIImageView!
    
    weak var manageVC: ManageUsersViewController?
    
    weak var importDBViewController: UIViewController?
    
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
            var tag = 1
            nameTextField.tag = tag
            tag = tag + 1
            if profileType == .employee {
                employeeBtn.isSelected = true
                employerBtn.isSelected = false
                addressTitleLabel.text = "home_address".localized
                
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
                employeeBtn.isSelected = false
                employerBtn.isSelected = true
                addressTitleLabel.text = "work_address".localized
                
                addressLine1View.isHidden = false
                addressLine2View.isHidden = false
                cityView.isHidden = false
                stateView.isHidden = false
                zipCodeView.isHidden = false

                street1TextField.tag = tag
                street2TextField.tag = tag+1
                cityTextField.tag = tag+2
                stateTextField.tag = tag+3
                zipcodeTextField.tag = tag+4
                tag = tag+5
            }
            
            phoneTextField.tag = tag
            emailTextField.tag = tag+1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
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
        requiredFooterLabel.scaleFont(forDataType: .footerText)
        
        scrollView.keyboardDismissMode = .onDrag
        setupAccessibility()
        
        displayInfo()
    }
    
    func setupAccessibility() {
        var titleLabel = "full_name".localized
        nameTextField.accessibilityLabel = titleLabel

        titleLabel.append(" ")
        titleLabel.append("required".localized)
        nameTitleLabel.accessibilityLabel =  titleLabel
        street1TextField.accessibilityLabel = "street1".localized
        street2TextField.accessibilityLabel = "street2".localized
        cityTextField.accessibilityLabel = cityTitleLabel.text
        stateTextField.accessibilityLabel = stateTitleLabel.text
        zipcodeTextField.accessibilityLabel = zipCodeTitleLabel.text
        phoneTextField.accessibilityLabel = phoneTitleLabel.text
        emailTextField.accessibilityLabel = emailTitleLabel.text
        
        stateTextField.accessibilityTraits = [.button, .staticText]
        stateTextField.accessibilityHint = "state_hint".localized
        
        if Util.isVoiceOverRunning {
            requiredFooterLabel.isHidden = true
        }
        else {
            requiredFooterLabel.isHidden = false
        }
        
        profileImageView.accessibilityHint = "profile_image_new_hint".localized
        
        holaHelloButton.isAccessibilityElement = true
        holaHelloButton.accessibilityTraits = .button
        
        if Localizer.currentLanguage == Localizer.ENGLISH {
            holaHelloButton.accessibilityHint = "switch_to_spanish".localized
        } else {
            holaHelloButton.accessibilityHint = "switch_to_english".localized
        }
    }
    
    func displayInfo() {
        guard let profileUser = viewModel.profileModel.currentUser else {
            manageEmploymentContentView.removeFromSuperview()
            
            profileType = .employee
            isWizard = true
            
            // if OldDB exists and hasn't been imported
            let versionUpdated = UserDefaults.standard.bool(forKey: updatedDBVersion)
            if versionUpdated == false, ImportDBService.dbExists {
                employerBtn.setTitleColor(.lightGray, for: .disabled)
                employerBtn.isEnabled = false
                employerBtn.isAccessibilityElement = false
                employeeEmployerInfoView.infoType = .importDBEmployee
            }
            setupLabels()
            return
        }
        setupLabels()

        employeeEmployerInfoView.infoType = .employee_Employer
        headerView.removeFromSuperview()
        footerView.removeFromSuperview()
        
//        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClicked(_:)))
//        navigationItem.leftBarButtonItem = cancelBtn
//
//        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveClicked(_:)))
//        navigationItem.rightBarButtonItem = saveBtn
        
        nameTextField.text = profileUser.name
        
        if viewModel.isProfileEmployer {
            street1TextField.text = profileUser.address?.street1
            street2TextField.text = profileUser.address?.street2
            cityTextField.text = profileUser.address?.city
            stateTextField.text = profileUser.address?.state
            zipcodeTextField.text = profileUser.address?.zipCode
        }
        
        phoneTextField.text = profileUser.phone
        emailTextField.text = profileUser.email
        profileImageView.maskCircle(anyImage: profileUser.image?.normalizedImage() ?? #imageLiteral(resourceName: "Default Profile Photo"))
        profileImageView.accessibilityHint = (profileUser.image == nil) ?
        "profile_image_new_hint".localized :
        "profile_image_hint".localized
        profileType = viewModel.profileModel.isEmployer ? .employer : .employee
        
    }
    
    func setupLabels() {
        if isWizard {
            nextBtn.setTitle("next".localized, for: .normal)
        }
        title = "my_profile".localized
        if let profileTitle = profileTitleLabel{
            profileTitle.text = "profile_setup".localized
        }
        if let profileSubTitle = profileSubTitleLabel{
            profileSubTitle.text = "please_setup_your_profile".localized
        }
        myProfileTitleLabel.text = "my_profile".localized
        requiredFooterLabel.text = "indicates_a_required_field".localized
        nameTitleLabel.text = "full_name_intro".localized
        nameTextField.placeholder = "required".localized
        cityTitleLabel.text = "city".localized
        stateTitleLabel.text = "state".localized
        zipCodeTitleLabel.text = "zip_code".localized
        zipcodeTextField.placeholder = "required".localized
        phoneTitleLabel.text = "phone".localized
        emailTitleLabel.text = "email".localized
        
        zipcodeTextField.attributedPlaceholder = NSAttributedString(string: "99999 or 99999-9999", attributes:
            [NSAttributedString.Key.foregroundColor:  UIColor.borderColor,
             NSAttributedString.Key.font: Style.scaledFont(forDataType: .nameValueText)])
        
        employeeEmployerInfoView.title = "employee_employer_profile".localized
        
        employeeBtn.setTitle("employee".localized, for: .normal)
        employerBtn.setTitle("employer".localized, for: .normal)
        
        if isWizard == false {
            let cancelBtn = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(cancelClicked(_:)))
            navigationItem.leftBarButtonItem = cancelBtn
            
            let saveBtn = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(saveClicked(_:)))
            navigationItem.rightBarButtonItem = saveBtn
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
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "back".localized
        navigationItem.backBarButtonItem = backItem
        
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
            destVC.viewModel = ProfileViewModel(context: viewModel.managedObjectContext)
            destVC.view.translatesAutoresizingMaskIntoConstraints = false
            destVC.isEmbeded = true
            destVC.delegate = delegate
            manageVC = destVC
        }
        else if let destVC = segue.destination as? ImportDBViewController {
            destVC.importDelegate = self
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
            UIAlertController(title: "confirm_title".localized,
                              message: "confirm_delete_employees".localized,
                              preferredStyle: .alert)
            
            alertController.addAction(
                UIAlertAction(title: "cancel".localized, style: .cancel))
            alertController.addAction(
                UIAlertAction(title: "delete".localized, style: .destructive) { _ in
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
            UIAlertController(title: "confirm_title".localized,
                              message: "confirm_delete_employers".localized,
                              preferredStyle: .alert)
            
            alertController.addAction(
                UIAlertAction(title: "cancel".localized, style: .cancel))
            alertController.addAction(
                UIAlertAction(title: "delete".localized, style: .destructive) { _ in
                    self.toggleUserType()
                }
            )
            present(alertController, animated: true)
        }
        else {
            toggleUserType()
        }
    }

    @IBAction func holaHelloPressed(_ sender: Any) {
        offerSpanish()
    }
    
    func offerSpanish() {
        
        let langUpdate = (Localizer.currentLanguage == Localizer.ENGLISH) ? Localizer.SPANISH : Localizer.ENGLISH
        
         let alertController =
             UIAlertController(title: " \n\n \("spanish_support".localized)",
                               message: nil,
                               preferredStyle: .alert)
         let imgViewTitle = UIImageView(frame: CGRect(x: 270/2-36.5, y: 10, width: 73, height: 50))
         imgViewTitle.image = UIImage(named:"holaHello")
         alertController.view.addSubview(imgViewTitle)
         
         alertController.addAction(
             UIAlertAction(title: "No", style: .cancel))
         alertController.addAction(
            UIAlertAction(title: "yes_si".localized, style: .destructive) { _ in
                Localizer.updateCurrentLanguage(lang: langUpdate)
                self.setupAccessibility()
                self.setupLabels()
                self.delegate?.didUpdateLanguageChoice()
                self.manageVC?.didUpdateLanguageChoice()
             }
         )
         present(alertController, animated: true)
     }
    @IBAction func nextClick(_ sender: Any) {
        guard validateInput() == true else {
            return
        }
        
        let userName = nameTextField.text ?? ""
        let userType = UserType(rawValue: employeeBtn.isSelected ? 0 : 1) ?? UserType.employee

        let profileUser = viewModel.profileModel.newProfile(type: userType, name: userName)

        saveProfile()
        
        handleNext(profileUser: profileUser)
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
        
        if viewModel.profileModel.isEmployer {
            let street1 = street1TextField.text?.trimmingCharacters(in: .whitespaces)
            let street2 = street2TextField.text?.trimmingCharacters(in: .whitespaces)
            let city = cityTextField.text?.trimmingCharacters(in: .whitespaces)
            let state = stateTextField.text?.trimmingCharacters(in: .whitespaces)
            let zipcode = zipcodeTextField.text?.trimmingCharacters(in: .whitespaces)
            profileUser.setAddress(street1: street1, street2: street2, city: city, state: state, zipCode: zipcode)
        }
        
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
            errorStr = "err_enter_name".localized
        }
        else if viewModel.isProfileEmployer,
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
            errorStr = "err_invalid_emailaddress".localized
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
                DispatchQueue.main.sync {
                    if success {
                        self.takeCameraPicture()
                    }
                }
            }
        case .restricted:
            ()
//            print("Access Restricted")
        @unknown default:
            ()
//            print("Unknown Error")
        }
    }
    
    func takeCameraPermission() {
        let title = "err_camera_denied_title".localized
        let alertController = UIAlertController(title: title,
                                                message: "err_camera_denied".localized,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "settings".localized, style: .default) { _ in
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
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: employeeEmployerView)
        }
        else {
            let nextTextField = view.viewWithTag(textField.tag + 1)
            nextTextField?.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
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


extension  SetupProfileViewController {
    func handleNext(profileUser: User) {

        view.endEditing(true)
        // If Old DB Exists and it hasn't been importted
        let versionUpdated = UserDefaults.standard.bool(forKey: updatedDBVersion)
        if versionUpdated == false, ImportDBService.dbExists {
            
            if profileUser is Employee {
                let controller = ImportDBViewController.instantiateFromStoryboard("Profile")
                controller.importDelegate = self
                addDBImportView(controller: controller)
            }
        }
        else {
            performSegue(withIdentifier: "addEmploymentInfo", sender: self)
        }
    }
}

extension SetupProfileViewController {
    private func addDBImportView(controller: UIViewController) {
        importDBViewController = controller
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(controller.view)

        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        controller.didMove(toParent: self)
        self.view.accessibilityElements = [controller.view as Any]
        UIAccessibility.post(notification: .layoutChanged, argument: controller.view)
    }
    
    func hideContentController(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}

extension SetupProfileViewController: ImportDBProtocol {
    func importDBSuccessful() {
        if let viewController = importDBViewController {
            hideContentController(controller: viewController)
        }
        
        UserDefaults.standard.set(true, forKey: updatedDBVersion)
        let controller = ImportDBSucessViewController.instantiateFromStoryboard("Profile")
        controller.importDelegate = self
        addDBImportView(controller: controller)
    }
    
    func importDBTimedOut() {
        if let viewController = importDBViewController {
            hideContentController(controller: viewController)
        }
        
        let controller = ImportDBFailedViewController.instantiateFromStoryboard("Profile")
        controller.importDelegate = self
        addDBImportView(controller: controller)
    }
    
    func importDBFinish() {
        delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
    func emailOldDB() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["webmaster@dol.gov"])
            mail.setSubject("Timesheet Import Data")
            mail.setMessageBody("<p>DOL Timesheet Support,</p> <p>Attached are the Timesheet import logs and the old timesheet database related to the error I had importing my data.</p>", isHTML: true)

            let dbPathURL = ImportDBService.dbPath
            let dbLogPathURL = ImportDBService.importLogPath
            do {
                let attachmentData = try Data(contentsOf: dbPathURL)
                mail.addAttachmentData(attachmentData, mimeType: "application/x-sqlite3", fileName: "whd.sqlite")

                let logAttachmentData = try Data(contentsOf: dbLogPathURL)
                mail.addAttachmentData(logAttachmentData, mimeType: "text/plain", fileName: "ImportLogs.txt")

            } catch let error {
            }
            present(mail, animated: true)
        } else {
            // show failure alert
            let alertController = UIAlertController(title: "Email",
                                                    message: "email not setup".localized,
                                                    preferredStyle: .alert)
            
            alertController.addAction(
                UIAlertAction(title: "Ok".localized, style: .default))
            present(alertController, animated: true)
        }
    }
}

extension SetupProfileViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ didFinishWithcontroller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        didFinishWithcontroller.dismiss(animated: false) { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
    }
}
