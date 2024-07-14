//
//  UpdateEmploymentTypeViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class UpdateEmploymentTypeViewController: UIViewController {
    @IBOutlet weak var employeeTitleLabel: UILabel!
    @IBOutlet weak var employeeCheckmarkImageView: UIImageView!
    @IBOutlet weak var employeeView: UIView!
    @IBOutlet weak var employerTitleLabel: UILabel!
    @IBOutlet weak var employerCheckmarkImageView: UIImageView!
    @IBOutlet weak var employerView: UIView!
    
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    
    weak var manageVC: ManageUsersViewController?
    lazy var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        self.navigationController?.navigationBar.tintColor = .linkColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        employeeView.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
        employerView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
    }
    
    func setupView() {
        setupLabels()
    }
    
    func setupLabels() {
        title = "i_am_employee".localized
        employeeTitleLabel.text = "employee".localized
        employerTitleLabel.text = "employer".localized

        employeeCheckmarkImageView.isHidden = false
        employerCheckmarkImageView.isHidden = true
        if profileViewModel.isProfileEmployer {
            title = "i_am_employer".localized
            employeeCheckmarkImageView.isHidden = true
            employerCheckmarkImageView.isHidden = false
        }
        
        switchLabel.text = "swicth_between_employment".localized
        warningLabel.text = "warning_swicth_between_employment".localized
    }
    
    @IBAction func employeePressed(_ sender: Any) {
        if let employer = profileViewModel.profileModel.currentUser as? Employer {
            changeToEmployee(employer: employer)
        }
    }
    
    fileprivate func changeToEmployee(employer: Employer) {
        if (employer.employees?.count ?? 0) > 0 {
            let alertController =
            UIAlertController(title: "confirm_title".localized,
                              message: "my_profile_confirm_delete_employees".localized,
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
    
    @IBAction func employerPressed(_ sender: Any) {
        if let employee = profileViewModel.profileModel.currentUser as? Employee {
            changeToEmployer(employee: employee)
        }
    }
    
    fileprivate func changeToEmployer(employee: Employee) {
        if (employee.employers?.count ?? 0) > 0 {
            let alertController =
            UIAlertController(title: "confirm_title".localized,
                              message: "my_profile_confirm_delete_employers".localized,
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
        var newEmpType = ""
        if let employer = profileViewModel.profileModel.currentUser as? Employer {
        //    profileViewModel.changeToEmployee(employer: employer)
            employeeCheckmarkImageView.isHidden = false
            employerCheckmarkImageView.isHidden = true
            newEmpType = TimesheetViewModel.forceOnboardingEmployee
        }
        else if let employee = profileViewModel.profileModel.currentUser as? Employee {
    //        profileViewModel.changeToEmployer(employee: employee)
            employeeCheckmarkImageView.isHidden = true
            employerCheckmarkImageView.isHidden = false
            newEmpType = TimesheetViewModel.forceOnboardingEmployer
        }
   //     profileViewModel.saveProfile()
        
        UserDefaults.standard.set(newEmpType, forKey: TimesheetViewModel.forceOnboarding)
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2 // 1 corresponds to the second tab, index starts from 0
        }
        
   //     manageVC?.profileViewModel = ProfileViewModel(context: profileViewModel.managedObjectContext.childManagedObjectContext())
        
        self.navigationController?.popToRootViewController(animated: false)
    }
}
