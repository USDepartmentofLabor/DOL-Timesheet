//
//  HourlyRateTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/18/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol HourlyRateCellDelegate: class {
    func removeItem(index: Int)
}

class HourlyRateTableViewCell: UITableViewCell {

    class var nibName: String { return "HourlyRateTableViewCell" }
    class var reuseIdentifier: String { return "HourlyRateTableViewCell" }
    
    var itemIndex: Int = 0
    weak var delegate: HourlyRateCellDelegate?

    @IBOutlet weak var rateTitleLabel: UILabel!
    @IBOutlet weak var rateNameTextField: UnderlinedTextField!
    @IBOutlet weak var rateValueTextField: UnderlinedTextField!
    @IBOutlet weak var perHourLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var hourlyRate: HourlyRate? {
        didSet {
            displayHourlyRate()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    func setupView() {
        rateTitleLabel.scaleFont(forDataType: .nameValueTitle)
        rateNameTextField.scaleFont(forDataType: .nameValueText)
        rateValueTextField.scaleFont(forDataType: .nameValueText)
        perHourLabel.scaleFont(forDataType: .nameValueText)
        
        rateNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        rateValueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [rateTitleLabel as Any, rateNameTextField as Any, rateValueTextField as Any, perHourLabel as Any, deleteBtn as Any]
        
        rateNameTextField.accessibilityLabel = rateTitleLabel.text
        rateValueTextField.accessibilityLabel = NSLocalizedString("rate_amount", comment: "Rate Amount")
        
        if Util.isVoiceOverRunning {
            rateValueTextField.keyboardType = .numbersAndPunctuation
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func removeBtnClick(_ sender: Any) {
        delegate?.removeItem(index: itemIndex)
    }

    func displayHourlyRate() {
        guard let rate = hourlyRate else { return }
        
        rateNameTextField.text = rate.name
        rateValueTextField.text = NumberFormatter.localisedCurrencyStr(from: rate.value)
        
        let deleteHint = NSLocalizedString("delete_rate_hint", comment: "Delete Rate?")
        let deleteMsg = String(format: deleteHint, rate.name ?? "")
        deleteBtn.accessibilityHint = deleteMsg
    }
}

extension HourlyRateTableViewCell {
    
    @objc func textFieldDidChange(_ textField: UITextField) {       
        if textField == rateValueTextField {
            let rate = textField.text?.currencyAmount() ?? NSNumber(0)
            textField.text = NumberFormatter.localisedCurrencyStr(from: rate)
            hourlyRate?.value = rate.doubleValue
        }
        else if textField == rateNameTextField {
            hourlyRate?.name = textField.text
            let deleteHint = NSLocalizedString("delete_rate_hint", comment: "Delete Rate?")
            let deleteMsg = String(format: deleteHint, hourlyRate?.name ?? "")
            deleteBtn.accessibilityHint = deleteMsg
        }
    }
}
