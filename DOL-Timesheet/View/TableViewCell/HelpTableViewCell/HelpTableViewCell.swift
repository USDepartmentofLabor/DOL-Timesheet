//
//  HelpTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 5/8/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class HelpTableViewCell: UITableViewCell {
    
    class var nibName: String { return "HelpTableViewCell" }
    class var reuseIdentifier: String { return "HelpTableViewCell" }

    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var helpLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setup() {
        helpLabel.text = "help".localized
        helpView.layer.cornerRadius = 10.0
        helpView.clipsToBounds = true
    }
    
}
