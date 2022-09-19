//
//  OnboardNameViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardNameViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var otherNameLabel: UILabel!
    @IBOutlet weak var otherNameField: UITextField!
    @IBOutlet weak var workweekLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var workweekField: UITextField!
    @IBOutlet weak var nameNoteLabel: UILabel!
    
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
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
    
    @IBAction func nameSet(_ sender: Any) {
        
        let userName = nameField.text ?? ""
//        let userType = UserType(rawValue: employeeBtn.isSelected ? 0 : 1) ?? UserType.employee
        
        let profileUser = viewModel.profileModel.newProfile(type: userType, name: userName)
        saveProfile()
    }
    
    @IBAction func otherNameSet(_ sender: Any) {
        
        let otherName = otherNameField.text ?? ""
    }
    
}
