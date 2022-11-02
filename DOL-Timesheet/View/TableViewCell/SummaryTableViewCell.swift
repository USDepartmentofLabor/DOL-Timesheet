//
//  SummaryTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/13/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {

    class var reuseIdentifier: String { return "SummaryTableViewCell" }

    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var totalOvertimeTitleLabel: UILabel!
    @IBOutlet weak var totalOvertimeLabel: UILabel!
    
    @IBOutlet weak var ovetimeHoursStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupView() {
        totalTitleLabel.scaleFont(forDataType: .summaryTotalTitle)
        totalValueLabel.scaleFont(forDataType: .summaryTotalValue)
        totalOvertimeTitleLabel.text = "overtime_summary".localized
        totalOvertimeTitleLabel.scaleFont(forDataType: .summaryTotalTitle)
        totalOvertimeLabel.scaleFont(forDataType: .summaryTotalValue)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [totalTitleLabel as Any, totalValueLabel as Any, totalOvertimeTitleLabel as Any, totalOvertimeLabel as Any]
    }
}
