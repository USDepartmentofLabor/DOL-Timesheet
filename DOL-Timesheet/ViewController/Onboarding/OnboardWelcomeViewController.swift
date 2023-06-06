//
//  OnboardWelcomeViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardWelcomeViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var employeeLabel: UILabel!
    @IBOutlet weak var employeeButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var employerLabel: UILabel!
    @IBOutlet weak var employerButton: UIButton!
    
//    lazy var viewModel
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
      //  canMoveForward = true
        canMoveForward = true
    }
    
    override func setupView() {
        title = "introduction".localized
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        titleLabel.text = NSLocalizedString("welcome_intro", comment: "Welcome to WHD's Timesheet App")
        employeeLabel.text = NSLocalizedString("onboard_welcome_employee", comment: "I want to use this app to help me keep track of my own time.")
        employeeButton.setTitle(NSLocalizedString("onboard_welcome_employee_button", comment: "Set me up as an employee"), for: .normal)
        orLabel.text = NSLocalizedString("or", comment: "OR")
        employerLabel.text = NSLocalizedString("onboard_welcome_employer", comment: "I want to use this app to help me keep track of other people's time.")
        employerButton.setTitle(NSLocalizedString("onboard_welcome_employer_button", comment: "Set me up as an employer"), for: .normal)
        
      //  titleLabel.scaleFont(forDataType: .introductionBoldText)
        //employeeLabel.scaleFont(forDataType: .italic)
      //  orLabel.scaleFont(forDataType: .introductionBoldText)
        //employerLabel.scaleFont(forDataType: .italic)
        
        employeeButton.addBorder(cornerRadius: 10.0)
        employerButton.addBorder(cornerRadius: 10.0)

        setupAccessibility()
    }
    
    override func saveData() -> Bool {
        print("OnboardWelcomeViewController SAVE DATA")
        return true
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
//        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
//        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
 //       nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setupProfile",
//            let setupVC = segue.destination as? SetupProfileViewController {
//            setupVC.delegate = delegate
//        }
//    }
    
    @IBAction func employeeSelected(_ sender: Any) {
        onboardingDelegate?.updateCanMoveForward(value:true)
        
        employerButton.tintColor = UIColor.white
        employeeButton.tintColor = UIColor(named: "onboardButtonColor")
        
        if let employee = profileViewModel!.profileModel.currentUser as? Employee {
            changeToEmployer(employee: employee)
        }
        
        onboardingDelegate?.updateUserType(newUserType: .employee)
        
        canMoveForward = true
    }
    
    @IBAction func employerSelected(_ sender: Any) {
        onboardingDelegate?.updateCanMoveForward(value: true)
        
        employerButton.tintColor = UIColor(named: "onboardButtonColor")
        employeeButton.tintColor = UIColor.white
        
        if let employer = profileViewModel!.profileModel.currentUser as? Employer {
            changeToEmployee(employer: employer)
        }
        
        onboardingDelegate?.updateUserType(newUserType: .employer)

        canMoveForward = true
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
    
    func toggleUserType() {
        if let employer = profileViewModel!.profileModel.currentUser as? Employer {
            profileViewModel!.changeToEmployee(employer: employer)
        }
        else if let employee = profileViewModel!.profileModel.currentUser as? Employee {
            profileViewModel!.changeToEmployer(employee: employee)
        }
        manageVC?.viewModel = ProfileViewModel(context: profileViewModel!.managedObjectContext.childManagedObjectContext())
    }
    
}
