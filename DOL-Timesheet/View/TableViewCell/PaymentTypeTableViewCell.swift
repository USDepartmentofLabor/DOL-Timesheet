//
//  PaymentTypeTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/16/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol PaymentTypeCellDelegate: class {
    func didSelect(paymentType: PaymentType)
}

class PaymentTypeTableViewCell: UITableViewCell {

    class var reuseIdentifier: String { return "PaymentTypeTableViewCell" }
    
    @IBOutlet weak var paymentTypeButton: UIButton!
    @IBOutlet weak var paymentTypeLabel: UILabel!
    var paymentType: PaymentType? {
        didSet {
            paymentTypeButton.setTitle(paymentType?.title, for: .normal)
            paymentTypeLabel.text = paymentType?.desc
        }
    }
    
    weak var delegate: PaymentTypeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        paymentTypeLabel.scaleFont(forDataType: .glossaryText)
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [paymentTypeButton as Any, paymentTypeLabel as Any]
    }
    
    @IBAction func paymentBtnClick(_ sender: Any) {
        if let paymentType = paymentType {
            delegate?.didSelect(paymentType: paymentType)
        }
    }
}
