//
//  ImportDBFailedViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ImportDBFailedViewController: UIViewController {

    
    @IBOutlet weak var dataView: ShadowView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var details1Label: UILabel!
    @IBOutlet weak var details2Label: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var yesBtn: SelectableButton!
    @IBOutlet weak var noBtn: SelectableButton!

    weak var importDelegate: ImportDBProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        dataView.addBorder(borderColor: .borderColor, borderWidth: 1.0, cornerRadius: 12.0)
        titleLabel.scaleFont(forDataType: .sectionTitle)
        details1Label.scaleFont(forDataType: .glossaryText)
        details2Label.scaleFont(forDataType: .glossaryText)
        footerLabel.scaleFont(forDataType: .glossaryTitle)
        yesBtn.isSelected = true
    }
    
    @IBAction func yesClick(_ sender: Any) {
        importDelegate?.emailOldDB()
    }
    
    @IBAction func noClick(_ sender: Any) {
        importDelegate?.importDBFinish()
    }
}
