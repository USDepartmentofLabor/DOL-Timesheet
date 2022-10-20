//
//  SettingProfileViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 10/13/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class SettingsProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesField: UITextField!
    
    lazy var viewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupView() {
        nameLabel.text = NSLocalizedString("name", comment: "Name or Nickname")
        notesLabel.text = NSLocalizedString("notes", comment: "Notes")
        
        guard let profileUser = viewModel.profileModel.currentUser else {
            return
        }
        
        nameField.text = profileUser.name
        
    }

    @IBAction func nameFieldChanged(_ sender: Any) {
        let profileUser = viewModel.profileModel.currentUser
        
        let name = nameField.text
        if name == nil || name!.isEmpty {
            navigationItem.backBarButtonItem?.isEnabled = false
        } else {
            profileUser?.name = nameField.text
            navigationItem.backBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func nameFieldEnd(_ sender: Any) {
        var errorStr: String? = nil
        
        let name = nameField.text
        if name == nil || name!.isEmpty {
            errorStr = NSLocalizedString("err_enter_name", comment: "Please provide User Name")
        }
        
        if let errorStr = errorStr {
            displayError(message: errorStr)
            return
        }
    }
}
