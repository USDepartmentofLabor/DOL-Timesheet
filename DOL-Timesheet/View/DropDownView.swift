//
//  LabelInfo.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

@IBDesignable
class DropDownView: UIView {

    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
            accessibilityLabel = title
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    var view: UIView!
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        titleLabel.scaleFont(forDataType: .barButtonTitle)
        self.view = view
        self.view.addBorder()
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
}
