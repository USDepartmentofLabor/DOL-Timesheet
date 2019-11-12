//
//  ImportDBSucessViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ImportDBSucessViewController: UIViewController {

    @IBOutlet weak var successView: ShadowView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    weak var importDelegate: ImportDBProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        successView.addBorder(borderColor: .borderColor, borderWidth: 1.0, cornerRadius: 12.0)
        titleLabel.scaleFont(forDataType: .sectionTitle)
        subTitleLabel.scaleFont(forDataType: .glossaryText)
    }
    
    @IBAction func okClick(_ sender: Any) {
        importDelegate?.importDBFinish()
    }
}
