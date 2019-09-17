//
//  ShadowView.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 9/9/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override func layoutSubviews() {
        let radius: CGFloat = frame.width / 2.0
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2.1 * radius, height: frame.height))
        
        layer.cornerRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.4)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
        layer.masksToBounds =  false
        layer.shadowPath = shadowPath.cgPath
    }
}
