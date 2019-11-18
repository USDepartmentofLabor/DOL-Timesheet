//
//  ImportDBFailedViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ImportDBFailedViewController: UIViewController {

    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var details1Label: UILabel!
    @IBOutlet weak var details2Label: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var yesBtn: SelectableButton!
    @IBOutlet weak var noBtn: SelectableButton!

    weak var importDelegate: ImportDBProtocol?
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        dataView.addBorder(borderColor: .borderColor, borderWidth: 1.0, cornerRadius: 8.0)
        titleLabel.scaleFont(forDataType: .sectionTitle)
        details1Label.scaleFont(forDataType: .glossaryText)
        details2Label.scaleFont(forDataType: .glossaryText)
        footerLabel.scaleFont(forDataType: .summaryTotalTitle)
        yesBtn.isSelected = true
        setupAccessibility()
    }
    
    func setupAccessibility() {
        yesBtn.accessibilityHint = NSLocalizedString("click yes to share", comment: "Click Yes to share")
        noBtn.accessibilityHint = NSLocalizedString("click no to not share", comment: "Click No to not share")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if shadowView.frame.maxY > view.frame.height {
            contentTopConstraint.constant = 0
        }

        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 8.0).cgPath
        shadowView.layer.shadowRadius = 8.0
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = 1
    }
    
    @IBAction func yesClick(_ sender: Any) {
        importDelegate?.emailOldDB()
    }
    
    @IBAction func noClick(_ sender: Any) {
        importDelegate?.importDBFinish()
    }
}
