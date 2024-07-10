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
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var employmentTitleLabel: UILabel!
    @IBOutlet weak var employmentTypeLabel: UILabel!
    @IBOutlet weak var employmentView: UIView!
    
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
        saveName()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameView.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
        employmentView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
        
    }
    
    func setupView() {
        title = "employee".localized

        nameTitleLabel.text = "name_or_nickname".localized
        nameTextField.text = profileViewModel.profileModel.currentUser?.name
        
        employmentTitleLabel.text = "I am an..."
        employmentTypeLabel.text = "employee".localized
        if profileViewModel.isProfileEmployer {
            title = "employer".localized
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
