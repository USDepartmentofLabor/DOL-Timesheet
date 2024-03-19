//
//  UIView+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(borderColor: UIColor? = UIColor.borderColor,
                   borderWidth: CGFloat = 1.0,
                   cornerRadius: CGFloat = 3.0) {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        let radius: CGFloat = frame.width / 2.0 //change it to .height if you need spread for height
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 2.1 * radius, height: frame.height))
        //Change 2.1 to amount of spread you need and for height replace the code for height

        layer.cornerRadius = 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.4)  //Here you control x and y
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0 //Here your control your blur
        layer.masksToBounds =  false
        layer.shadowPath = shadowPath.cgPath
        
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
