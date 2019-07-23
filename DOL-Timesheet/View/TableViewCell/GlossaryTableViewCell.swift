//
//  GlossaryTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 6/20/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class GlossaryTableViewCell: UITableViewCell {

    class var reuseIdentifier: String { return "GlossaryTableViewCell" }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    
    @IBOutlet weak var descHeightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        setupView()
    }
    
    func setupView() {
        titleLabel.scaleFont(forDataType: .glossaryTitle)
        descLabel.scaleFont(forDataType: .glossaryText)
        descLabel.linkTextAttributes = [NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.foregroundColor:  UIColor(named: "linkColor")!]

        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements  = [titleLabel as Any, descLabel as Any]
    }
}
