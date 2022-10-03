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
    
    @IBOutlet weak var payFrequencyPickerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    var otherName: String?
    var nameValid: Bool = false
    var otherNameValid: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        canMoveForward = false
    }
    
    override func saveData() {
        print("OnboardNameViewController SAVE DATA")
        
        let userName = nameField.text ?? ""
//        let userType = UserType(rawValue: employeeBtn.isSelected ? 0 : 1) ?? UserType.employee
        
        userProfile = viewModel.profileModel.newProfile(type: userType, name: userName)
        
        employmentModel = viewModel.newTempEmploymentModel()
        guard let employmentModel = employmentModel else { return }
        var user = employmentModel.employmentUser
        if user == nil {
            user = employmentModel.newEmploymentUser()
        }
//        user?.name = otherNameField.text?.trimmingCharacters(in: .whitespaces)
        employmentModel.supervisorName = otherNameField.text?.trimmingCharacters(in: .whitespaces)
        
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        setupAccessibility()
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
    
    @IBAction func nameSet(_ sender: Any) {
        var errorStr: String? = nil
        
        let name = nameField.text
        if name == nil || name!.isEmpty {
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide User Name")
        }
        
        if let errorStr = errorStr {
            displayError(message: errorStr)
            return
        }
        check()
    }
    
    @IBAction func otherNameSet(_ sender: Any) {
        var errorStr: String? = nil
        
        let otherName = otherNameField.text
        if otherName == nil || otherName!.isEmpty {
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide Employer/Employee Name")
        }

        if let errorStr = errorStr {
            displayError(message: errorStr)
            return
        }
        check()
    }
    
    func check() {
        if (nameValid && otherNameValid) {
            canMoveForward = true
        } else {
            canMoveForward = false
        }
    }
}
