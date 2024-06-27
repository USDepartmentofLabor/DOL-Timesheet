//
//  MyProfileViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var employmentLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var employmentTable: UITableView!
    @IBOutlet weak var employmentTableHeightConstraint: NSLayoutConstraint!
        
    var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
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
        userLabel.text = profileViewModel.profileModel.currentUser?.name
        
        employmentLabel.text = "employee".localized
        if profileViewModel.isProfileEmployer {
            employmentLabel.text = "employer".localized
        }
    }
}

extension MyProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileViewModel.numberOfEmploymentInfo + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: SoftenProfileTableViewCell.reuseIdentifier) as! SoftenProfileTableViewCell
        
        let employmentModel = profileViewModel.employmentModels[indexPath.row]
        
        if profileViewModel.isProfileEmployer {
            cell.employmentLabel.text = employmentModel.employeeName
        }
        else {
            cell.employmentLabel.text = employmentModel.employerName
        }
            
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEmployment(indexPath: indexPath)
        }
    }
    
    func deleteEmployment(indexPath: IndexPath) {
        let employmentModel = profileViewModel.employmentModels[indexPath.row]
        
        let titleMsg: String
        let errorMsg: String
        if employmentModel.isProfileEmployer {
            titleMsg = "delete_employee".localized
            errorMsg = "delete_confirm_employee_info".localized
        }
        else {
            titleMsg = "delete_employer".localized
            errorMsg = "delete_confirm_employer_info".localized
        }
        
        let alertController = UIAlertController(title: titleMsg,
                                                message: errorMsg,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "delete".localized, style: .destructive) { _ in
                self.profileViewModel.deleteEmploymentModel(employmentModel: employmentModel)
                self.employmentTable.beginUpdates()
                self.employmentTable.deleteRows(at: [indexPath], with: .automatic)
                self.employmentTable.endUpdates()
                self.employmentTableHeightConstraint.constant = self.employmentTable.contentSize.height
        })
        
        present(alertController, animated: true)
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedModel = profileViewModel.employmentModels[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        let employmentModel = profileViewModel.tempEmploymentModel(for: selectedModel)

        
        if let setupVC = navigationController?.topViewController as? UpdateEmploymentViewController,
            let employmentModel = employmentModel {
            //setupVC.editClicked(employmentModel: employmentModel)
            performSegue(withIdentifier: "updateEmploymentSegue", sender: employmentModel)
        }
        else {
            performSegue(withIdentifier: "updateEmploymentSegue", sender: employmentModel)
        }
    }
}
