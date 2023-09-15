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
    
    @IBInspectable var value: String = "" {
        didSet {
            valueLabel.text = value
            accessibilityLabel = value
        }
    }

    @IBInspectable var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                self.view.backgroundColor = .clear
            }
            else {
                self.view.backgroundColor = UIColor(named: "disabledColor")
            }
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
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
        valueLabel.scaleFont(forDataType: .barButtonTitle)
        self.view = view
        self.view.addBorder(borderColor: .darkGray)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
}
