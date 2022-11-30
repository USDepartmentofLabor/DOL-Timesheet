//
//  SetupBaseEmploymentViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/17/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SetupBaseEmploymentViewController: UIViewController {
    var viewModel: EmploymentModel?
    
    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        configureView()
    }
    
    func configureView() {
//        if viewModel?.isWizard == false {
//            let skipBtn = UIBarButtonItem(title: "skip".localized, style: .plain, target: self, action: #selector(skipClicked(_:)))
//
//            if let viewModel = viewModel, viewModel.isProfileEmployer {
//                skipBtn.accessibilityHint = "skip_employee_hint".localized
//            }
//            else {
//                skipBtn.accessibilityHint = "skip_employer_hint".localized
//            }
//
//            navigationItem.rightBarButtonItem = skipBtn
//        }
    }
    
    @IBAction func skipClicked(_ sender: Any) {
        delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelClicked(_ sender: Any) {
        delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? SetupBaseEmploymentViewController {
            destVC.viewModel = viewModel
            destVC.delegate = delegate
        }
    }
}
