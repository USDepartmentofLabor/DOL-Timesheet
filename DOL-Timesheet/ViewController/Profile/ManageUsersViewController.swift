//
//  ManageUsersViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/7/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ManageUsersViewController: UIViewController {

    var profileViewModel: ProfileViewModel? {
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
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    func didUpdateLanguageChoice() {
        displayInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if profileViewModel?.numberOfEmploymentInfo ?? 0 <= 0 {
            editBtn.isEnabled = false
        }
        else {
            editBtn.isEnabled = true
        }
    }
    
    func setupView() {
        title = profileViewModel?.manageUsersTitle
        let cancelBtn = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action:  #selector(cancelClick(sender:)))
        navigationItem.leftBarButtonItem = cancelBtn

        let saveBtn = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(saveClick(sender:)))
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
        addressHeaderTitleLabel.text = "address".localized
        paymentTypeHeaderTitleLabel.text = "payment_type".localized
        editBtn.setTitle("edit".localized, for: .normal)
        if profileViewModel?.isProfileEmployer ?? false {
            titleLabel.text = "employees".localized
            userHeaderTitleLabel.text = "employee".localized
            addBtn.accessibilityLabel = "add_employee".localized
            addressHeaderTitleLabel.isHidden = true
        }
        else {
            titleLabel.text = "employers".localized
            userHeaderTitleLabel.text = "employer".localized
            addBtn.accessibilityLabel = "add_employer".localized
            addressHeaderTitleLabel.isHidden = false
        }
        
        if userNameLabel != nil {
            userNameLabel.text = profileViewModel?.profileModel.currentUser?.name
        }
        
        tableView.reloadData()
        
        if let safeProfileViewModel = profileViewModel, safeProfileViewModel.numberOfEmploymentInfo <= 0 {
            noView.isHidden = false
            noUsersLabel.isHidden = false
            noUsersLabel.text = safeProfileViewModel.isProfileEmployer ?
            "no_employees".localized :
            "no_employers".localized
        }
        else {
            noView.isHidden = true
            noUsersLabel.isHidden = true
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
        profileViewModel?.saveProfile()
        
        delegate?.didUpdateEmploymentInfo()
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func editClick(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        editUsers(edit: tableView.isEditing)
    }
    
    func editUsers(edit: Bool) {
        if edit {
            editBtn.setTitle("done".localized, for: .normal)
        }
        else {
            editBtn.setTitle("edit".localized, for: .normal)
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
        guard let safeProfileViewModel = profileViewModel else {
            return
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "back".localized
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "addEmploymentInfo",
            let employmentVC = segue.destination as? EmploymentInfoViewController {
            employmentVC.employmentModel = safeProfileViewModel.newTempEmploymentModel()
            employmentVC.delegate = delegate
        }
        else if segue.identifier == "editEmploymentInfo",
            let vc = segue.destination as? EmploymentInfoViewController,
            let employmentViewModel = sender as? EmploymentModel {
                vc.employmentModel = employmentViewModel
                vc.delegate = delegate
        }
    }
}

extension ManageUsersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileViewModel?.numberOfEmploymentInfo ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier) as! ProfileTableViewCell
        
        guard let employmentModel = profileViewModel?.employmentModels[indexPath.row] else {
            return cell
        }
        
        if profileViewModel?.isProfileEmployer ?? false {
            cell.nameLabel.text = employmentModel.employeeName
//            cell.addressLabel.text = employmentModel.employeeAddress?.description
            cell.addressLabel.isHidden = true
        }
        else {
            cell.nameLabel.text = employmentModel.employerName
            cell.addressLabel.text = employmentModel.employerAddress?.description
            cell.addressLabel.isHidden = false
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
        guard let employmentModel = profileViewModel?.employmentModels[indexPath.row] else {
            return
        }
        
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
                self.profileViewModel?.deleteEmploymentModel(employmentModel: employmentModel)
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
        guard let safeProfileViewModel = profileViewModel else {
            return
        }

        let selectedModel = safeProfileViewModel.employmentModels[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        let employmentModel = safeProfileViewModel.tempEmploymentModel(for: selectedModel)

        
        if let setupVC = navigationController?.topViewController as? SetupProfileViewController,
            let employmentModel = employmentModel {
            setupVC.editClicked(employmentModel: employmentModel)
        }
        else {
            performSegue(withIdentifier: "editEmploymentInfo", sender: employmentModel)
        }
    }
}
