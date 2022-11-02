//
//  MinimumWageViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/17/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class MinimumWageViewController: UIViewController {
   
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var eligibilityContentView: UIView!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    
    @IBOutlet weak var minimumWageContentView: UIView!
    @IBOutlet weak var minimumWageTextField: UITextField!
    @IBOutlet weak var eligibleTitleLabelInfo: LabelInfoView!
    
    @IBOutlet weak var minimuWageLabelInfoView: LabelInfoView!
    @IBOutlet weak var federalWageLabel: UILabel!
    
    @IBOutlet weak var perhourLabel: UILabel!
    @IBOutlet weak var minimumWageFooterLabel: UILabel!
    @IBOutlet weak var minimumWageBtn: SubActionButton!
    
    var isProfileEmployer: Bool = false {
        didSet {
            if isProfileEmployer {
                eligibleTitleLabelInfo.title = "overtime_eligible_employer".localized
            }
            else {
                eligibleTitleLabelInfo.title = "overtime_eligible_employee".localized
            }
        }
    }

    var paymentType: PaymentType? {
        didSet {
            if paymentType == .salary || paymentType == .hourly {
                minimumWageFooterLabel.isHidden = true
            }
            else {
                minimumWageFooterLabel.isHidden = false
            }
        }
    }
    var overtimeEligible: Bool = true {
        didSet {
            if isViewLoaded {
                yesBtn.isSelected = overtimeEligible
                noBtn.isSelected = !overtimeEligible
            }
        }
    }
    
    var minimumWage: NSNumber = 0.0 {
        didSet {
            if isViewLoaded {
                minimumWageTextField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        displayInfo()
    }
    
    func setupView() {
        federalWageLabel.scaleFont(forDataType: .nameValueText)
        perhourLabel.scaleFont(forDataType: .nameValueText)
        minimumWageTextField.addTarget(self, action: #selector(minimumWageDidChange(_:)), for: .editingChanged)
        
        yesBtn.setTitle("yes".localized, for: .normal)
        noBtn.setTitle("no".localized, for: .normal)
        
        minimuWageLabelInfoView.title = "what_is_minimum_wage_title".localized
        federalWageLabel.text = "federal_wage_label".localized
        perhourLabel.text = "per_hour".localized
        minimumWageBtn.setTitle("minimum_wage_table".localized, for: .normal)
        
        
        eligibilityContentView.addBorder()
        minimumWageContentView.addBorder()
        minimumWageFooterLabel.isHidden = true
        eligibleTitleLabelInfo.delegate = self
        minimuWageLabelInfoView.delegate = self
        
        minimuWageLabelInfoView.infoType = .minimumWage
        eligibleTitleLabelInfo.infoType = .overtimeEligible

        minimumWageTextField.delegate = self
        setupAccessibility()
    }
    
    func setupAccessibility() {
        if Util.isVoiceOverRunning {
            minimumWageTextField.keyboardType = .numbersAndPunctuation
        }
        
        minimumWageTextField.accessibilityLabel = "minimum_wage_amount".localized
    }
    
    func displayInfo() {
        minimumWageTextField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
        yesBtn.isSelected = overtimeEligible
        noBtn.isSelected = !overtimeEligible
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "minimumWage",
            let destVC = segue.destination as? WebInfoViewController {
            destVC.webInfo = .minimumWage
        }
    }
    
    @IBAction func yesBtnClick(_ sender: Any) {
        overtimeEligible = true
    }
    
    
    @IBAction func noBtnClick(_ sender: Any) {
        overtimeEligible = false
    }
}

extension MinimumWageViewController {
    func validateInput() -> String? {
        
        var errorStr: String? = nil
            // Minimum Wage should be greater than 0
        if minimumWage.compare(NSNumber(0)) != .orderedDescending {
            errorStr = "err_enter_valid_minimum_wage".localized
        }
        
        return errorStr
    }
}

extension MinimumWageViewController {
    @objc func minimumWageDidChange(_ textField: UITextField) {
        minimumWage = textField.text?.currencyAmount() ?? NSNumber(0)
        textField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
    }
}

extension MinimumWageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: perhourLabel)
        }
        return true
    }
}
