//
//  OnboardIntroductionViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardIntroductionViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var introLabel1: UILabel!
    @IBOutlet weak var introLabel2: UILabel!
    @IBOutlet weak var introLabel3: UILabel!
    @IBOutlet weak var introNoteLabel: UILabel!
    
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
        canMoveForward = true
    }
    
    override func saveData() {
        print("OnboardIntroductionViewController SAVE DATA")
    }
    
    override func setupView() {
        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        introductionLabel.text = NSLocalizedString("introduction", comment: "Introduction")
        introLabel1.text = NSLocalizedString("onboard_intro_1", comment: "This app is for your personal use and we don't share your information with anyone.")
        introLabel2.text = NSLocalizedString("onboard_intro_2", comment: "We will guide you through the setup by asking you a few questions that will help you get started.")
        introLabel3.text = NSLocalizedString("onboard_intro_3", comment: "Please answer all of the questions and don't worry, you'll be able to change things later in the app's Settings.")
        introNoteLabel.text = NSLocalizedString("onboard_intro_note", comment: "Tap the right arrow below to continue.")

        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
//        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
//        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
//        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfile",
            let setupVC = segue.destination as? SetupProfileViewController {
            setupVC.delegate = delegate
        }
    }
}
