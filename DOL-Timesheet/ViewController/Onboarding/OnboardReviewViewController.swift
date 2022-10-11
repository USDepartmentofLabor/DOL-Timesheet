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
        canMoveForward = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    @IBAction func letsGoPressed(_ sender: Any) {
        employmentModel?.save()
       // delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
    func displayInfo() {
        if (userType == .employee) {
            reviewNameLabel.text = "You are " + (profileViewModel!.profileModel.currentUser!.name ?? "John Doe") + ", an employee"
            reviewOtherNameLabel.text = "You work for " + (employmentModel?.employmentUser?.name ?? "John Smith")
            reviewWorkweekLabel.text = "Your employer's workweek starts on " + (employmentModel?.workWeekStartDay.title ?? "Monday")
            reviewPayTypeLabel.text = "You are paid " + (employmentModel?.paymentFrequency.title ?? "Unknown")
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                reviewPayRateLabel.text = "Your pay rate is $" + (String((employmentModel?.hourlyRates![0].value)!)) + "/hour"
            }else {
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    reviewPayRateLabel.text = "Your pay rate is $" + String(amount) + "/annual"
                } else if SalaryType == .monthly {
                    reviewPayRateLabel.text = "Your pay rate is $" + String(amount) + "/month"
                } else if SalaryType == .weekly {
                    reviewPayRateLabel.text = "Your pay rate is $" + String(amount) + "/week"
                }
            }
            
            if (employmentModel?.overtimeEligible == true) {
                reviewOvertimeLabel.text = "You are eligible for overtime (non-exempt)"
            } else {
                reviewOvertimeLabel.text = "You are not eligible for overtime (exempt)"
            }
            reviewStateLabel.text = "You work in " + (employmentModel?.employmentUser?.address?.state ?? "West Virginia")
        } else {
            reviewNameLabel.text = "You are " + (profileViewModel!.profileModel.currentUser!.name ?? "John Doe") + ", an employer"
            reviewOtherNameLabel.text = "Your employee's name is " + (employmentModel?.employmentUser?.name ?? "John Smith")
            reviewWorkweekLabel.text = "Your workweek starts on " + (employmentModel?.workWeekStartDay.title ?? "Monday")
            reviewPayTypeLabel.text = "Your employee is paid " + (employmentModel?.paymentFrequency.title ?? "Unknown")
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                reviewPayRateLabel.text = "Your employee's pay rate is $" + (String((employmentModel?.hourlyRates![0].value)!)) + "/hour"
            }else {
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    reviewPayRateLabel.text = "Your employee's pay rate is $" + String(amount) + "/annual"
                } else if SalaryType == .monthly {
                    reviewPayRateLabel.text = "Your employee's pay rate is $" + String(amount) + "/month"
                } else if SalaryType == .weekly {
                    reviewPayRateLabel.text = "Your employee's pay rate is $" + String(amount) + "/week"
                }
            }
            
            if (employmentModel?.overtimeEligible == true) {
                reviewOvertimeLabel.text = "Your employee is eligible for overtime (non-exempt)"
            } else {
                reviewOvertimeLabel.text = "Your employee is not eligible for overtime (non-exempt)"
            }
            reviewStateLabel.text = "Your employee works in " + (employmentModel?.employmentUser?.address?.state ?? "West Virginia")
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
