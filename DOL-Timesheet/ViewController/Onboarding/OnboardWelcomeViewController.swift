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
        canMoveForward = true
    }
    
    override func setupView() {
        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        titleLabel.scaleFont(forDataType: .introductionBoldText)
        //employeeLabel.scaleFont(forDataType: .italic)
        orLabel.scaleFont(forDataType: .introductionBoldText)
        //employerLabel.scaleFont(forDataType: .italic)
        
        employeeButton.addBorder()
        employerButton.addBorder()
        employeeButton.setTitle("Set me up as an employee", for: .normal)
        employerButton.setTitle("Set me up as an employer", for: .normal)
        
        setupAccessibility()
    }
    
    override func saveData() {
        print("OnboardWelcomeViewController SAVE DATA")
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
        onboardingDelegate?.canMoveForward(vcIndex: vcIndex)
        
        employerButton.tintColor = UIColor.white
        employeeButton.tintColor = UIColor.systemBlue
        
        if let employee = viewModel.profileModel.currentUser as? Employee {
            changeToEmployer(employee: employee)
        }
    }
    
    @IBAction func employerSelected(_ sender: Any) {
        
        onboardingDelegate?.canMoveForward(vcIndex: vcIndex)
        
        employerButton.tintColor = UIColor.systemBlue
        employeeButton.tintColor = UIColor.white
        
        if let employer = viewModel.profileModel.currentUser as? Employer {
            changeToEmployee(employer: employer)
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
    
    func toggleUserType() {
        if let employer = viewModel.profileModel.currentUser as? Employer {
            viewModel.changeToEmployee(employer: employer)
        }
        else if let employee = viewModel.profileModel.currentUser as? Employee {
            viewModel.changeToEmployer(employee: employee)
        }
        manageVC?.viewModel = ProfileViewModel(context: viewModel.managedObjectContext.childManagedObjectContext())
    }
    
}
