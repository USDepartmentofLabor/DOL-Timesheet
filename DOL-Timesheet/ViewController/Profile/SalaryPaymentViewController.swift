//
//  SalaryPaymentViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/6/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SalaryPaymentViewController: UIViewController {
    
    var viewModel: EmploymentModel!

    @IBOutlet weak var titleLabelInfo: LabelInfoView!
    @IBOutlet weak var salaryTitleLabel: UILabel!
    @IBOutlet weak var salaryContentView: UIView!
    
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var salaryTextField: UITextField!
    
    @IBOutlet weak var salaryTypeView: DropDownView!
    
    var salaryAmount: NSNumber = 0.0 {
        didSet {
            if isViewLoaded {
                salaryTextField.text = NumberFormatter.localisedCurrencyStr(from: salaryAmount)
            }
        }
    }
    
    var salaryType: SalaryType = .annually {
        didSet {
            if isViewLoaded {
                salaryTypeView.title = salaryType.title
            }
        }
    }
    
    var isProfileEmployer: Bool = false {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            if isProfileEmployer {
                titleLabelInfo.title = NSLocalizedString("salary_employer", comment: "Salary")
                titleLabelInfo.infoType = .employer_salary
            }
            else {
                titleLabelInfo.title = NSLocalizedString("salary_employee", comment: "Salary")
                titleLabelInfo.infoType = .employee_salary
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }
    
    func setupView() {
        salaryTitleLabel.scaleFont(forDataType: .headingTitle)
        salaryLabel.scaleFont(forDataType: .nameValueTitle)
        salaryTextField.scaleFont(forDataType: .nameValueText)
        salaryContentView.addBorder()
        salaryTextField.addTarget(self, action: #selector(salaryAmountDidChange(_:)), for: .editingChanged)
        
        let salaryTypeTapGesture = UITapGestureRecognizer(target: self, action: #selector(salaryTypeClick(_:)))
        salaryTypeTapGesture.cancelsTouchesInView = false
        salaryTypeView.addGestureRecognizer(salaryTypeTapGesture)

        titleLabelInfo.delegate = self
        setupAccessibility()
    }
    
    func setupAccessibility() {
        salaryTypeView.accessibilityHint = NSLocalizedString("salary_type_hint", comment:  "Tap to select Salary type")

        salaryContentView.accessibilityElements = [titleLabelInfo as Any, salaryLabel as Any, salaryTextField as Any, salaryTypeView as Any]
        
        if Util.isVoiceOverRunning {
            salaryTextField.keyboardType = .numbersAndPunctuation
            salaryTextField.delegate = self
        }
    }
    
    func displayInfo() {
        if let salary = viewModel?.salary {
            salaryAmount = salary.amount
            salaryType = salary.salaryType
        }
        
        isProfileEmployer = viewModel.isProfileEmployer
    }
    
    @IBAction func salaryTypeClick(_ sender: Any) {
        let vc = OptionsListViewController(options: SalaryType.allCases,
                                           title: "")
        vc.didSelect = { [weak self] (popVC: UIViewController, salaryType: SalaryType?) in
            guard let strongSelf = self else { return }
            strongSelf.salaryType = salaryType ?? SalaryType.annually
            popVC.dismiss(animated: true, completion: nil)
        }
        
        showPopup(popupController: vc, sender: salaryTypeView)
    }
}

extension SalaryPaymentViewController {
    @objc func salaryAmountDidChange(_ textField: UITextField) {
        salaryAmount = textField.text?.currencyAmount() ?? NSNumber(0)
    }
}

extension SalaryPaymentViewController {
    func validateInput() -> String? {
        var errorStr: String? = nil
        
        // Salary Amount should be greater than 0
        if salaryAmount.compare(NSNumber(0)) != .orderedDescending {
            errorStr = NSLocalizedString("err_enter_valid_salary", comment: "Enter valid Salary amount")
        }
        return errorStr
    }
}

extension SalaryPaymentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        return true
    }
}
