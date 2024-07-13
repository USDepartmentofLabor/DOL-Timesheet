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
        self.navigationController?.navigationBar.tintColor = .linkColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileView.layer.cornerRadius = 10.0
        updateCellCorners()
    }
    
    func setupView() {
        navigationItem.hidesBackButton = true
        title = "my_profile".localized
        
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
        employmentTableHeightConstraint.constant = employmentTable.contentSize.height
        return profileViewModel.numberOfEmploymentInfo + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SoftenProfileTableViewCell.reuseIdentifier) as! SoftenProfileTableViewCell

        if indexPath.row == profileViewModel.numberOfEmploymentInfo {
            cell.employmentLabel.text = "Add an Employer..."

            if profileViewModel.isProfileEmployer {
                cell.employmentLabel.text = "Add an Employee..."
            }
            
            return cell
        }
        
        let employmentModel = profileViewModel.employmentModels[indexPath.row]
        
        cell.employmentLabel.text = employmentModel.employerName

        if profileViewModel.isProfileEmployer {
            cell.employmentLabel.text = employmentModel.employeeName
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = "my_employers".localized
        if profileViewModel.isProfileEmployer {
            title = "my_employees".localized
        }
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "timesheetBackgroundColor")

        let headerLabel = UILabel(frame: CGRect(x: 5, y: -5, width: tableView.frame.width - 30, height: 12))
        headerLabel.text = title
        headerLabel.textColor = UIColor(named: "labelTextInactive")
        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15 // Change this to your desired height
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row == profileViewModel.numberOfEmploymentInfo {
            return
        }
        
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
    
    private func updateCellCorners() {
        let numberOfRows = employmentTable.numberOfRows(inSection: 0)
        
        for (index, cell) in employmentTable.visibleCells.enumerated() {
            guard let roundedCell = cell as? SoftenProfileTableViewCell else { continue }
            
            roundedCell.layer.mask = nil
            
            if numberOfRows - 1 == 0 {
                roundedCell.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
            } else if index == numberOfRows - 1 {
                roundedCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
            } else if index == 0{
                roundedCell.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            }
        }
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == profileViewModel.numberOfEmploymentInfo {
            tableView.deselectRow(at: indexPath, animated: false)
            performSegue(withIdentifier: "updateEmploymentSegue", sender: nil)
            return
        }

        let selectedModel = profileViewModel.employmentModels[indexPath.row]
        let employmentModel = profileViewModel.tempEmploymentModel(for: selectedModel)

        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "updateEmploymentSegue", sender: employmentModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateEmploymentSegue" {
            if let destinationVC = segue.destination as? UpdateEmploymentViewController,
               let model = sender as? EmploymentModel {
                destinationVC.employmentModel = model
            }
        }
    }
}
