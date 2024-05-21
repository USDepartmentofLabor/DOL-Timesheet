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
    
    @IBOutlet weak var rateHintTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rateHintHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mimimumWarningHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var minimumWarningValueHeightConstraint: NSLayoutConstraint!
    
    
    var firstItem: Bool = false
    var lastItem: Bool = false
    
    var value = "0.0"
    var hours = 0
    var rate = 7.25
    
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
    public func configure(isTotalEarnings: Bool = false, hasWarning: Bool = false, warningEnabled: Bool = false) {
        self.addborder()
        
        minimumWarningTitle.text = "minimum_wage_warning".localized
        
        rateHintTitle.isHidden = true
        rateHint.isHidden = true
        
        mimimumWarningHeightConstraint.isActive = true
        mimimumWarningHeightConstraint.constant = 0
        minimumWarningValueHeightConstraint.constant = 0
        
        
        if isTotalEarnings {
            
            if hasWarning && warningEnabled {
                mimimumWarningHeightConstraint.isActive = false
                minimumWarningValueHeightConstraint.constant = 12
            }
            
            contentView.layoutIfNeeded()
            return
        }
        
        rateHintTitle.isHidden = false
        rateHint.isHidden = false
        
        if hasWarning && warningEnabled {
            mimimumWarningHeightConstraint.isActive = false
            minimumWarningValueHeightConstraint.constant = 12
        }
        
        contentView.layoutIfNeeded()
    }
    
}
