//
//  OnboardDetailsViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardDetailsViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var payFrequencyTitle: UILabel!
    @IBOutlet weak var infoFrequencyButton: UIButton!
    
    @IBOutlet weak var payRateTitle: UILabel!
    @IBOutlet weak var infoPayRateButton: UIButton!
    @IBOutlet weak var payRateField: UITextField!
    @IBOutlet weak var payRateStart: UIDatePicker!
    
    @IBOutlet weak var overtimeTitle: UILabel!
    @IBOutlet weak var infoOvertimeButton: UIButton!
    @IBOutlet weak var yesOvertimeButton: UIButton!
    @IBOutlet weak var noOvertimeButton: UIButton!
    
    @IBOutlet weak var stateTitle: UILabel!
    
    
    @IBOutlet weak var noteTitle: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    override func saveData() {
        print("OnboardDetailsViewController SAVE DATA")
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
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
//        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setupProfile",
//            let setupVC = segue.destination as? SetupProfileViewController {
//            setupVC.delegate = delegate
//        }
//    }
}
