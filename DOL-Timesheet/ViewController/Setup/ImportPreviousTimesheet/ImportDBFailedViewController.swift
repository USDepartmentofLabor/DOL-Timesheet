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
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var details1Label: UILabel!
    @IBOutlet weak var details2Label: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var yesBtn: SelectableButton!
    @IBOutlet weak var noBtn: SelectableButton!

    weak var importDelegate: ImportDBProtocol?
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        dataView.addBorder(borderColor: .borderColor, borderWidth: 1.0, cornerRadius: 8.0)
        titleLabel.scaleFont(forDataType: .sectionTitle)
        details1Label.scaleFont(forDataType: .glossaryText)
        details2Label.scaleFont(forDataType: .glossaryText)
        footerLabel.scaleFont(forDataType: .resourcesTitleText)
        yesBtn.isSelected = true
        setupAccessibility()
    }
    
    func setupAccessibility() {
        yesBtn.accessibilityHint = "click_yes_to_share".localized
        noBtn.accessibilityHint = "click_no_to_not_share".localized
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if shadowView.frame.minY + scrollView.contentSize.height < view.frame.maxY {
            contentViewHeightConstraint.constant = scrollView.contentSize.height
        }
        else {
            contentViewHeightConstraint.constant = view.frame.height - 10 - shadowView.frame.minY
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
