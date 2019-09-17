//
//  IntroductionViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }
    
    func setupView() {
        title = "Introduction"
        label1.scaleFont(forDataType: .introductionText)
        label2.scaleFont(forDataType: .introductionBoldText)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    func displayInfo() {
        label1.text = NSLocalizedString("introduction_text1", comment: "Introduction Text1")
        label2.text = NSLocalizedString("introduction_text2", comment: "Introduction Text2")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfile",
            let setupVC = segue.destination as? SetupProfileViewController {
            setupVC.delegate = delegate
        }
    }
}

