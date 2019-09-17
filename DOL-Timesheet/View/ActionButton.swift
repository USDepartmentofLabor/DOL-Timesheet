//
//  ActionButton.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor(named: "appPrimaryColor")
        layer.cornerRadius = 4.0
        
        titleLabel?.scaleFont(forDataType: .actionButton)
        setTitleColor(.white, for: .normal)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        addConstraint(heightConstraint)

        contentEdgeInsets.left = 20
        contentEdgeInsets.right = 20
        contentEdgeInsets.top = 10
        contentEdgeInsets.bottom = 10
    }
    
    override var intrinsicContentSize: CGSize {
        let size = self.titleLabel!.intrinsicContentSize
        return CGSize(width: size.width + contentEdgeInsets.left + contentEdgeInsets.right, height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }

}


class NavigationButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor(named: "navButtonColor")
        layer.cornerRadius = 4.0

        titleLabel?.scaleFont(forDataType: .navigationButton)
        setTitleColor(.white, for: .normal)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        addConstraint(heightConstraint)

        contentEdgeInsets.left = 20
        contentEdgeInsets.right = 20
        contentEdgeInsets.top = 10
        contentEdgeInsets.bottom = 10
        titleLabel?.lineBreakMode = .byWordWrapping
    }
    
}

class SubActionButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        backgroundColor = UIColor(named: "appPrimaryColor")
        layer.cornerRadius = 4.0
        
        titleLabel?.scaleFont(forDataType: .subActionButton)
        setTitleColor(.white, for: .normal)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        addConstraint(heightConstraint)
        contentEdgeInsets.left = 10
        contentEdgeInsets.right = 10
        contentEdgeInsets.top = 5
        contentEdgeInsets.bottom = 5

        titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    override var intrinsicContentSize: CGSize {
        let size = self.titleLabel!.intrinsicContentSize
        return CGSize(width: size.width + contentEdgeInsets.left + contentEdgeInsets.right, height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }
}
