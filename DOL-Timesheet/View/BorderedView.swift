//
//  BorderedView.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 6/6/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class BorderedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        addBorder()
    }

}
