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
        let appNavBarColor = UIColor.appNavBarColor
        
        setTitleColor(appNavBarColor, for: .normal)
        setTitleColor(.white, for: .selected)
        setTitleColor(.black, for: .normal)
        addBorder(borderColor: appNavBarColor)
        titleLabel?.scaleFont(forDataType: .actionButton)
    }
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                backgroundColor = UIColor.appNavBarColor
            }
            else {
                backgroundColor = .white
            }
        }
    }
    
    

}
