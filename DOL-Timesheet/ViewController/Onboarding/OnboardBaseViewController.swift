//
//  OnboardBaseViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/14/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

protocol OnboardingProtocol: AnyObject {
    func canMoveForward(vcIndex: Int)
}

class OnboardBaseViewController: UIViewController {
    let updatedDBVersion = "UpdatedDBVersion"
    var isWizard: Bool = false
    var userType: UserType = .employee
    
    var onboardingDelegate: OnboardingProtocol?
    var canMoveForward: Bool = false
    var vcIndex: Int = 0
    
    weak var manageVC: ManageUsersViewController?
    var viewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    
    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func saveData() {
        print("OnboardBaseViewController SAVE DATA")
    }
    
    func setupView() {
        configureView()
    }
    
    func configureView() {
    //    guard let profileUser = viewModel.profileModel.currentUser else {
//            manageEmploymentContentView.removeFromSuperview()
//            
//            profileType = .employee
            isWizard = true
            
            // if OldDB exists and hasn't been imported
            let versionUpdated = UserDefaults.standard.bool(forKey: updatedDBVersion)
            if versionUpdated == false, ImportDBService.dbExists {
//                employerBtn.setTitleColor(.lightGray, for: .disabled)
//                employerBtn.isEnabled = false
//                employerBtn.isAccessibilityElement = false
//                employeeEmployerInfoView.infoType = .importDBEmployee
            }
            
            
//        if viewModel?.isWizard ?? false {
//            let skipBtn = UIBarButtonItem(title: NSLocalizedString("skip", comment: "Skip"), style: .plain, target: self, action: #selector(skipClicked(_:)))
//
//            if let viewModel = viewModel, viewModel.isProfileEmployer {            skipBtn.accessibilityHint = NSLocalizedString("skip_employee_hint", comment: "Skip Adding Employee")
//            }
//            else {
//                skipBtn.accessibilityHint = NSLocalizedString("skip_employer_hint", comment: "Skip Adding Employer")
//            }
//            
//            navigationItem.rightBarButtonItem = skipBtn
//        }
     //   }
//    }
    
//    @IBAction func skipClicked(_ sender: Any) {
//        delegate?.didUpdateUser()
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func cancelClicked(_ sender: Any) {
//        delegate?.didUpdateUser()
//        dismiss(animated: true, completion: nil)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destVC = segue.destination as? OnboardBaseViewController {
//            destVC.viewModel = viewModel
//            destVC.delegate = delegate
//        }
//    }
}
}

