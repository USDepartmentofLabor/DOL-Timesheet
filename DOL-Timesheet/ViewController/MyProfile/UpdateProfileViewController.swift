//
//  UpdateProfileViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class UpdateProfileViewController: UIViewController {
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var employmentTypeLabel: UILabel!
    
    lazy var profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarSettings()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        saveName()
    }
    
    func setupView() {
        nameTitleLabel.text = "name_nickname".localized
        nameTextField.text = profileViewModel.profileModel.currentUser?.name
        
        employmentTitleLabel.text = "I am an..."
        employmentTypeLabel.text = "employee".localized
        if profileViewModel.isProfileEmployer {
            employmentTypeLabel.text = "employer".localized
        }
    }
    
    func saveName() {
        let profileUser = profileViewModel.profileModel.currentUser
        
        let name = nameTextField.text
        if name != nil && !name!.isEmpty {
            profileUser?.name = nameTextField.text
            navigationItem.backBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func nameFieldChanged(_ sender: Any) {
        saveName()
    }

}
