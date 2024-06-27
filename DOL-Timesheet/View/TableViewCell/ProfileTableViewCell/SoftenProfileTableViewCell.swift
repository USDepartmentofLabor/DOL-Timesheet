//
//  ProfileTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/14/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class SoftenProfileTableViewCell: UITableViewCell {
    class var nibName: String { return "SoftenProfileTableViewCell" }
    class var reuseIdentifier: String { return "SoftenProfileTableViewCell" }

    @IBOutlet weak var employmentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
