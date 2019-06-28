//
//  ButonWithInfo.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ButonWithInfo: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        imageView?.image = #imageLiteral(resourceName: "dropDownArrow")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: (bounds.width - 45), bottom: 5, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
    }

}

class InfoButton: UIButton {
    var infoType = Info.unknown

    @IBInspectable private var infoTypeValue : String {
        set {
            infoType = Info(rawValue: newValue) ?? .unknown
        }
        get {
            return infoType.rawValue
        }
    }
    
    weak var delegate: InfoViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        addTarget(self, action: #selector(touchBtn(sender:)), for: .touchDown)
    }
    
    
    @objc func touchBtn(sender: Any) {
        delegate?.displayInfoPopup(sender, info: infoType)
    }
}



