//
//  EarningDetailTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 5/4/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class EarningDetailTableViewCell: UITableViewCell {
    
    class var nibName: String { return "EarningDetailTableViewCell" }
    class var reuseIdentifier: String { return "EarningDetailTableViewCell" }

    @IBOutlet weak var rateTitle: UILabel!
    @IBOutlet weak var rateValue: UILabel!
    
    @IBOutlet weak var rateHintTitle: UILabel!
    @IBOutlet weak var rateHint: UILabel!
    
    @IBOutlet weak var minimumWarningTitle: UILabel!
    @IBOutlet weak var minimumWarningValue: UILabel!
    
    var firstItem: Bool = false
    var lastItem: Bool = false
    
    var value = "0.0"
    var hours = 0
    var rate = 7.25
    
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func addborder() {
        topBackgroundView.layer.cornerRadius = firstItem ? 10.0 : 0.0
        topBackgroundView.clipsToBounds = true
        bottomBackgroundView.layer.cornerRadius = lastItem ? 10.0 : 0.0
        bottomBackgroundView.clipsToBounds = true
    }
    
    public func configure(isTotalEarnings: Bool = false, isBelowMinimumWage: Bool = false) {
        self.addborder()
        
        if isTotalEarnings {
            setupTotalEarning(warning: isBelowMinimumWage)
            return
        }
        setupEarningPeriod(warning: isBelowMinimumWage)
    }
    
    private func setupTotalEarning(warning: Bool) {
        rateHintTitle.isHidden = true
        rateHint.isHidden = true
        minimumWarningTitle.isHidden = true
        minimumWarningValue.isHidden = true
        
        if warning {
            minimumWarningTitle.isHidden = false
        }
        
    }
    
    private func setupEarningPeriod(warning: Bool) {
        rateHintTitle.isHidden = false
        rateHint.isHidden = false
        minimumWarningTitle.isHidden = true
        minimumWarningValue.isHidden = true
        
        if warning {
            minimumWarningTitle.isHidden = false
            minimumWarningValue.isHidden = false
        }
        
    }
    
}
