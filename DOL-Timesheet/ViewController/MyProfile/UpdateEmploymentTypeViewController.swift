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
    @IBOutlet weak var employerTitleLabel: UILabel!
    @IBOutlet weak var employerCheckmarkImageView: UIImageView!
    
    weak var manageVC: ManageUsersViewController?
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
        
        setupLabels()
    }
    
    func setupLabels() {
        employeeTitleLabel.text = "employee".localized
        employerTitleLabel.text = "employer".localized

        employeeCheckmarkImageView.isHidden = false
        employerCheckmarkImageView.isHidden = true
        if profileViewModel.isProfileEmployer {
            employeeCheckmarkImageView.isHidden = true
            employerCheckmarkImageView.isHidden = false
        }
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
    
    @IBAction func employerPressed(_ sender: Any) {
        if let employee = profileViewModel.profileModel.currentUser as? Employee {
            changeToEmployer(employee: employee)
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
        if let employer = profileViewModel.profileModel.currentUser as? Employer {
            profileViewModel.changeToEmployee(employer: employer)
            employeeCheckmarkImageView.isHidden = false
            employerCheckmarkImageView.isHidden = true
            
        }
        else if let employee = profileViewModel.profileModel.currentUser as? Employee {
            profileViewModel.changeToEmployer(employee: employee)
            employeeCheckmarkImageView.isHidden = true
            employerCheckmarkImageView.isHidden = false
        }
        
        manageVC?.profileViewModel = ProfileViewModel(context: profileViewModel.managedObjectContext.childManagedObjectContext())
    }
}
