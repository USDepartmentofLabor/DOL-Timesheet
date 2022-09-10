//
//  OnboardIntroductionViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardIntroductionViewController: UIViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var nextButton: NavigationButton!
    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    func setupView() {
        title = NSLocalizedString("introduction", comment: "Introduction")
        label1.scaleFont(forDataType: .introductionBoldText)
        label2.scaleFont(forDataType: .introductionText)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfile",
            let setupVC = segue.destination as? SetupProfileViewController {
            setupVC.delegate = delegate
        }
    }
}
