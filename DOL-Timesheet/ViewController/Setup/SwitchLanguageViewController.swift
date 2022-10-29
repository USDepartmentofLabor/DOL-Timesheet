//
//  SwitchLanguageViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 10/28/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class SwitchLanguageViewController: UIViewController {
    
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var firstInstructionLabel: UILabel!
    @IBOutlet weak var secondInstructionLabel: UILabel!
    @IBOutlet weak var thirdInstructionLabel: UILabel!
    @IBOutlet weak var fourthInstructionLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    func setupView() {
        title = NSLocalizedString("switchLanguage", comment: "Switch to English")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
//        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
//        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
//        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        primaryLabel.text = NSLocalizedString("primaryLang", comment: "Primary Language the ")
        secondaryLabel.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        firstInstructionLabel.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        secondInstructionLabel.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        thirdInstructionLabel.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        fourthInstructionLabel.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
//        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
        getStartedButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }
    
}

