//
//  OnboardReviewViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardReviewViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    
    @IBOutlet weak var reviewSetupLabel: UILabel!
    @IBOutlet weak var reviewNameLabel: UILabel!
    @IBOutlet weak var reviewOtherNameLabel: UILabel!
    @IBOutlet weak var reviewWorkweekLabel: UILabel!
    @IBOutlet weak var reviewPayTypeLabel: UILabel!
    @IBOutlet weak var reviewPayRateLabel: UILabel!
    @IBOutlet weak var reviewOvertimeLabel: UILabel!
    @IBOutlet weak var reviewStateLabel: UILabel!
    
    @IBOutlet weak var reviewConfirmButton: UIButton!
    
    @IBOutlet weak var reviewNote: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
//    weak var delegate: TimeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
        displayInfo()
    }
    
    override func saveData() {
        print("OnboardReviewViewController SAVE DATA")
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
        if (userType == .employee) {
            reviewNameLabel.text = "You are " + (viewModel.profileModel.currentUser!.name ?? "John Doe") + ", an employee"
        reviewOtherNameLabel.text = "You work for " + 
        reviewWorkweekLabel.text = "Your employer's workweek starts on Monday"
        reviewPayTypeLabel.text = "You are paid bi-weekly"
        reviewPayRateLabel.text = "Your pay rate is $10.00/hour"
        reviewOvertimeLabel.text = "You are eligible for overtime (non-exempt)"
        reviewStateLabel.text = "You work in West Virginia"
        }
//        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setupProfile",
//            let setupVC = segue.destination as? SetupProfileViewController {
//            setupVC.delegate = delegate
//        }
//    }
}
