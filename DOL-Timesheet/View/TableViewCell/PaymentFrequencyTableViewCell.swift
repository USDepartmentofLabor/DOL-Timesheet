//
//  PaymentFrequencyTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/29/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol PaymentFrequencyCellDelegate: class {
    func select(paymentFrequency: PaymentFrequency?)
}


class PaymentFrequencyTableViewCell: UITableViewCell {
    class var nibName: String { return "PaymentFrequencyTableViewCell" }
    class var reuseIdentifier: String { return "PaymentFrequencyTableViewCell" }
    
    @IBOutlet weak var paymentFrequencyBtn: UIButton!
    var paymentFrequency: PaymentFrequency?  {
        didSet {
            var title: String = ""
            if let paymentFrequency = paymentFrequency {
                title = paymentFrequency.title
            }
            
            paymentFrequencyBtn.setTitle(title, for: .normal)
        }
    }
    
    weak var delegate: PaymentFrequencyCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnClick(_ sender: Any) {
        delegate?.select(paymentFrequency: paymentFrequency)
    }
}
