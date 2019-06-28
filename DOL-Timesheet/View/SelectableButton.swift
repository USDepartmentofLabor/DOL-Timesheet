//
//  SelectableButton.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SelectableButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        let appPrimaryColor = UIColor.appPrimaryColor
        
        setTitleColor(appPrimaryColor, for: .normal)
        setTitleColor(.white, for: .selected)
        addBorder(borderColor: appPrimaryColor)
        titleLabel?.scaleFont(forDataType: .actionButton)
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                backgroundColor = UIColor.appPrimaryColor
            }
            else {
                backgroundColor = .white
            }
        }
    }
    
    

}
