//
//  MyProfileViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    
    var isWizard: Bool = false
    lazy var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        navigationItem.hidesBackButton = true
        
        
        setupAccessibility()
        
        displayInfo()
    }
    
    func setupAccessibility() {
        
    }
    
    func displayInfo() {
        guard let profileUser = profileViewModel.profileModel.currentUser else {
            
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
        
        profileType = profileViewModel.profileModel.isEmployer ? .employer : .employee
        
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
}
