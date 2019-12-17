//
//  LabelInfo.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol InfoViewDelegate: class {
    func displayInfoPopup(_ sender: Any, info: Info)
}

@IBDesignable
class LabelInfoView: UIView {

    @IBInspectable var title: String = "" {
        didSet {
            label.text = title
        }
    }
    
    var infoType = Info.unknown
    
    @IBInspectable private var infoTypeValue : String {
        set {
            infoType = Info(rawValue: newValue) ?? .unknown
        }
        get {
            return infoType.rawValue
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    var view: UIView!
    
    weak var delegate: InfoViewDelegate?
    
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
        label.scaleFont(forDataType: .questionTitle)
        
        label.textColor = UIColor(named: "darkTextColor")
        self.view = view
    }
    
    @IBAction func infoClicked(_ sender: Any) {
        delegate?.displayInfoPopup(self, info: infoType)
    }
}
