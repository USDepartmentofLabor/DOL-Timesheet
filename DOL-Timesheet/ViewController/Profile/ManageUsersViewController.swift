//
//  ManageUsersViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/7/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ManageUsersViewController: UIViewController {

    var viewModel: ProfileViewModel? {
        didSet {
            if isViewLoaded {
                displayInfo()
            }
        }
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var employmentView: UIView!
    
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var noUsersLabel: UILabel!
    @IBOutlet weak var userHeaderTitleLabel: UILabel!
    @IBOutlet weak var addressHeaderTitleLabel: UILabel!
    @IBOutlet weak var paymentTypeHeaderTitleLabel: UILabel!

    @IBOutlet weak var employmentTableViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: TimeViewControllerDelegate?
    
    var isEmbeded = false {
        didSet {
            if isEmbeded == true, headerView != nil {
                headerView.removeFromSuperview()
                headerView = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel?.numberOfEmploymentInfo ?? 0 <= 0 {
            editBtn.isEnabled = false
        }
        else {
            editBtn.isEnabled = true
        }
    }
    
    func setupView() {
        title = viewModel?.manageUsersTitle
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClick(sender:)))
        navigationItem.leftBarButtonItem = cancelBtn

        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveClick(sender:)))
        navigationItem.rightBarButtonItem = saveBtn

        employmentView.addBorder()
        userNameLabel.scaleFont(forDataType: .headingTitle)

        titleLabel.scaleFont(forDataType: .sectionTitle)
        
        userHeaderTitleLabel.scaleFont(forDataType: .columnHeader)
        addressHeaderTitleLabel.scaleFont(forDataType: .columnHeader)
        paymentTypeHeaderTitleLabel.scaleFont(forDataType: .columnHeader)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
        editBtn.titleLabel?.scaleFont(forDataType: .actionButton)
        setupAccessibility()
    }
    
    func setupAccessibility() {
        titleLabel.accessibilityTraits = .header
    }
    
    func displayInfo() {
        if viewModel?.isProfileEmployer ?? false {
            titleLabel.text = NSLocalizedString("employees", comment: "Employees")
            userHeaderTitleLabel.text = NSLocalizedString("employee", comment: "Employee")
            addBtn.accessibilityLabel = NSLocalizedString("add_employee", comment: "Add Employee")
        }
        else {
            titleLabel.text = NSLocalizedString("employers", comment: "Employers")
            userHeaderTitleLabel.text = NSLocalizedString("employer", comment: "Employer")
            addBtn.accessibilityLabel = NSLocalizedString("add_employer", comment: "Add Employer")
        }
        
        if userNameLabel != nil {
            userNameLabel.text = viewModel?.profileModel.currentUser?.name
        }
        
        tableView.reloadData()
        
        if let viewModel = viewModel, viewModel.numberOfEmploymentInfo <= 0 {
            noView.isHidden = false
            noUsersLabel.isHidden = false
            noUsersLabel.text = viewModel.isProfileEmployer ?
                NSLocalizedString("no_employees", comment: "No Employees") :
            NSLocalizedString("no_employers", comment: "No Employees")
        }
        else {
            noView.isHidden = true
            noUsersLabel.isHidden = true
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.tableView.layoutIfNeeded()
        }) { (complete) in
            self.employmentTableViewHeightConstraint.constant = self.tableView.contentSize.height > 0 ? self.tableView.contentSize.height : 100
        }
    }
    
    
    @objc func cancelClick(sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveClick(sender: Any?) {
        viewModel?.saveProfile()
        
        delegate?.didUpdateEmploymentInfo()
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func editClick(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        editUsers(edit: tableView.isEditing)
    }
    
    func editUsers(edit: Bool) {
        if edit {
           editBtn.setTitle(NSLocalizedString("done", comment: "Done"), for: .normal)
        }
        else {
            editBtn.setTitle(NSLocalizedString("edit", comment: "Edit"), for: .normal)
        }
    }
    
    @IBAction func addClick(_ sender: Any) {
        if let setupVC = navigationController?.topViewController as? SetupProfileViewController {
            setupVC.addClicked()
        }
        else {
            performSegue(withIdentifier: "addEmploymentInfo", sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewModel = viewModel else {
            return
        }
        
        if segue.identifier == "addEmploymentInfo",
            let employmentVC = segue.destination as? EmploymentInfoViewController {
            employmentVC.viewModel = viewModel.newTempEmploymentModel()
            employmentVC.delegate = delegate
        }
        else if segue.identifier == "editEmploymentInfo",
            let vc = segue.destination as? EmploymentInfoViewController,
            let employmentViewModel = sender as? EmploymentModel {
                vc.viewModel = employmentViewModel
                vc.delegate = delegate
        }
    }
}

extension ManageUsersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfEmploymentInfo ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as! ProfileTableViewCell
        
        guard let employmentModel = viewModel?.employmentModels[indexPath.row] else {
            return cell
        }
        
        if viewModel?.isProfileEmployer ?? false {
            cell.nameLabel.text = employmentModel.employeeName
            cell.addressLabel.text = employmentModel.employeeAddress?.description
        }
        else {
            cell.nameLabel.text = employmentModel.employerName
            cell.addressLabel.text = employmentModel.employerAddress?.description
        }
            
        cell.paymentLabel.text = employmentModel.paymentTypeTitle
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
        guard let employmentModel = viewModel?.employmentModels[indexPath.row] else {
            return
        }
        
        let titleMsg: String
        let errorMsg: String
        if employmentModel.isProfileEmployer {
            titleMsg = NSLocalizedString("delete_employee", comment: "Delete Employee")
            errorMsg = NSLocalizedString("delete_confirm_employee_info", comment: "Are you sure you want to delete Employee")
        }
        else {
            titleMsg = NSLocalizedString("delete_employer", comment: "Delete Employer")
            errorMsg = NSLocalizedString("delete_confirm_employer_info", comment: "Are you sure you want to delete Employer")
        }
        
        let alertController = UIAlertController(title: titleMsg,
                                                message: errorMsg,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("cancel", comment: "Cancel"), style: .cancel))
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("delete", comment: "Delete"), style: .destructive) { _ in
                self.viewModel?.deleteEmploymentModel(employmentModel: employmentModel)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                self.employmentTableViewHeightConstraint.constant = self.tableView.contentSize.height
        })
        
        present(alertController, animated: true)
    }
}


extension ManageUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }

        let selectedModel = viewModel.employmentModels[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        let employmentModel = viewModel.tempEmploymentModel(for: selectedModel)

        
        if let setupVC = navigationController?.topViewController as? SetupProfileViewController,
            let employmentModel = employmentModel {
            setupVC.editClicked(viewModel: employmentModel)
        }
        else {
            performSegue(withIdentifier: "editEmploymentInfo", sender: employmentModel)
        }
    }
}
