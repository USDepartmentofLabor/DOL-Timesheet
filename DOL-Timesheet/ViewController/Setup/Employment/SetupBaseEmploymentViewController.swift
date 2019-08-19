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
    
    weak var delegate: TimesheetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        configureView()
    }
    
    func configureView() {
        if viewModel?.isWizard ?? false {
            let skipBtn = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(skipClicked(_:)))

            if let viewModel = viewModel, viewModel.isProfileEmployer {            skipBtn.accessibilityHint = NSLocalizedString("skip_employee_hint", comment: "Skip Adding Employee")
            }
            else {
                skipBtn.accessibilityHint = NSLocalizedString("skip_employer_hint", comment: "Skip Adding Employer")
            }
            
            navigationItem.rightBarButtonItem = skipBtn
        }
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
