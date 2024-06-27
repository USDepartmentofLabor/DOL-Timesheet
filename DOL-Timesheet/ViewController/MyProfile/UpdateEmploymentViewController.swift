//
//  UpdateEmploymentViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class UpdateEmploymentViewController: UIViewController {
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var startOfPayWeekLabel: UILabel!
    @IBOutlet weak var startOfPayWeekTextField: UITextField!
    @IBOutlet weak var startOfPayWeekPicker: UIPickerView!
    @IBOutlet weak var startOfPayWeekHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstPayPeriodTitleLabel: UILabel!
    @IBOutlet weak var firstPayPeriodLabel: UITextField!
    @IBOutlet weak var firstPayPeriodDatePicker: UIDatePicker!
    
    @IBOutlet weak var payFrequencyTitleLabel: UILabel!
    @IBOutlet weak var payFrequencyLabel: UITextField!
    @IBOutlet weak var payFrequencyPicker: UIPickerView!
    
    @IBOutlet weak var overtimeLabel: UILabel!
    @IBOutlet weak var overtimeSwitch: UISwitch!
    
    @IBOutlet weak var stateTitleLabel: UILabel!
    @IBOutlet weak var stateLabel: UITextField!
    @IBOutlet weak var statePicker: UIPickerView!
    
    @IBOutlet weak var stateMinimumWageLabel: UILabel!
    @IBOutlet weak var stateMinimumWageTextField: UITextField!
    
    @IBOutlet weak var rateTable: SelfSizedTableView!
    
    
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var helpView: UIView!
    
    
    var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    var employmentModel: EmploymentModel!


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
    }
    
    func setupView() {
//        nameLabel.text = "name_or_nickname"
//        nameTextField.
//        startOfPayWeekLabel.text = "name_or_nickname"
//        startOfPayWeekTextField
//        startOfPayWeekPicker
//        startOfPayWeekHeightConstraint
//        firstPayPeriodTitleLabel.text = "name_or_nickname"
//        firstPayPeriodLabel.text = "name_or_nickname"
//        firstPayPeriodDatePicker
//        payFrequencyTitleLabel.text = "name_or_nickname"
//        payFrequencyLabel.text = "name_or_nickname"
//        payFrequencyPicker
//        overtimeLabel.text = "name_or_nickname"
//        overtimeSwitch
//        stateTitleLabel.text = "name_or_nickname"
//        stateLabel.text = "name_or_nickname"
//        statePicker
//        stateMinimumWageLabel.text = "name_or_nickname"
//        stateMinimumWageTextField
//        rateTable
//        helpLabel.text = "name_or_nickname"
//        helpView
        
    }
}

extension UpdateEmploymentViewController: UITableViewDataSource {
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
                self.rateTable.beginUpdates()
                self.rateTable.deleteRows(at: [indexPath], with: .automatic)
                self.rateTable.endUpdates()
            
        })
        
        present(alertController, animated: true)
    }
}

extension UpdateEmploymentViewController: UITableViewDelegate {
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
