//
//  TitleValueLabel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/21/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class TitleValueLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        scaleFont(forDataType: .nameValueTitle)
        textColor = UIColor(named: "appTextColor")
    }
}
