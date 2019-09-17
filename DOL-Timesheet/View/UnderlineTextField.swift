//
//  UnderlineTextField.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/18/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class UnderlinedTextField: UITextField, UITextFieldDelegate {
    
    var lineView: UIView!
    
    required init?(coder aDecoder: (NSCoder?)) {
        super.init(coder: aDecoder!)
        
        configure()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        delegate = self
        backgroundColor = UIColor.clear
        scaleFont(forDataType: .nameValueText)
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        lineView.backgroundColor = UIColor(named: "textBorderColor")
        self.addSubview(lineView)
        
        // VFL AutoLayout
        let dicViews : [String : Any] = ["vUnderline": lineView as Any]
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vUnderline]|", options: [], metrics: nil, views: dicViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vUnderline(1)]|", options: NSLayoutConstraint.FormatOptions.alignAllBottom, metrics: nil, views: dicViews))
    }
}

class UnderlinedButton: UIButton {
    
    var lineView: UIView!
    
    required init?(coder aDecoder: (NSCoder?)) {
        super.init(coder: aDecoder!)
        
        configure()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor.clear
        titleLabel?.scaleFont(forDataType: .nameValueText)
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0.5))
        lineView.backgroundColor = UIColor.borderColor
        self.addSubview(lineView)
        
        // VFL AutoLayout
        let dicViews : [String : Any] = ["vUnderline": lineView as Any]
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vUnderline]|", options: [], metrics: nil, views: dicViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vUnderline(1)]|", options: NSLayoutConstraint.FormatOptions.alignAllBottom, metrics: nil, views: dicViews))
    }
}
