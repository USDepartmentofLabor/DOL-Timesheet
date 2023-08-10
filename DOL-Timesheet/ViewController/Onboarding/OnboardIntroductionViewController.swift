//
//  OnboardIntroductionViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardIntroductionViewController: OnboardBaseViewController {

    
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var introLabel1: UILabel!
    @IBOutlet weak var introLabel2: UILabel!
    @IBOutlet weak var introLabel3: UILabel!
    @IBOutlet weak var introLabel4: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        canMoveForward = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
        displayInfo()
    }
    
    override func saveData() -> Bool {
        print("OnboardIntroductionViewController SAVE DATA")
        return true
    }
    
    override func setupView() {
        title = "introduction".localized
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        introductionLabel.text = "introduction".localized
        introLabel1.text = "onboard_intro_1".localized
        introLabel2.text = "onboard_intro_2".localized
        introLabel3.text = "onboard_intro_3".localized
        introLabel4.text = "onboard_intro_4".localized
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
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
