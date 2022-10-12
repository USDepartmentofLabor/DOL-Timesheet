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
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        reviewTitleLabel.text = NSLocalizedString("onboard_review_title", comment: "You're almost done!")
        reviewSetupLabel.text = NSLocalizedString("onboard_review_intro", comment: "Let's review your setup:")
        reviewConfirmButton.setTitle(NSLocalizedString("onboard_review_button", comment: "Looks good, let's go!"), for: .normal)
        reviewNote.text = NSLocalizedString("onboard_review_note", comment: "Note: if something doesn't look right, go back to previous steps to make your changes")
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
//        displayLogo.accessibilityLabel = NSLocalizedString("whd_logo", comment: "WHD Logo")
    }

    override func saveData() {
        print("OnboardReviewViewController SAVE DATA")
    }
    
    @IBAction func letsGoPressed(_ sender: Any) {
        employmentModel?.save()
        timeSheetDelegate?.didUpdateEmploymentInfo()
       // delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
    func displayInfo() {
        if (userType == .employee) {
            reviewNameLabel.text = NSLocalizedString("onboard_review_name", comment: "You are ") + (profileViewModel!.profileModel.currentUser!.name ?? "John Doe") + NSLocalizedString("onboard_review_employee", comment: ", an employee")
            reviewOtherNameLabel.text = NSLocalizedString("onboard_review_employee_employer", comment: "You work for ") + (employmentModel?.employmentUser?.name ?? "John Smith")
            reviewWorkweekLabel.text = NSLocalizedString("onboard_review_employee_workweek", comment: "Your employer's workweek starts on ") + (employmentModel?.workWeekStartDay.title ?? "Monday")
            reviewPayTypeLabel.text = NSLocalizedString("onboard_review_employee_frequency", comment: "You are paid ") + (employmentModel?.paymentFrequency.title ?? "Unknown")
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                reviewPayRateLabel.text = NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $") + (String((employmentModel?.hourlyRates![0].value)!)) + "/" + NSLocalizedString("payment_type_hourly", comment: "Hourly")
            }else {
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    reviewPayRateLabel.text = NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $") + String(amount) + "/" + NSLocalizedString("salary_annually", comment: "Annually")
                } else if SalaryType == .monthly {
                    reviewPayRateLabel.text = NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $") + String(amount) + "/" + NSLocalizedString("salary_monthly", comment: "Monthly")
                } else if SalaryType == .weekly {
                    reviewPayRateLabel.text = NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $") + String(amount) + "/" + NSLocalizedString("salary_weekly", comment: "Weekly")
                }
            }
            
            if (employmentModel?.overtimeEligible == true) {
                reviewOvertimeLabel.text = NSLocalizedString("onboard_review_employee_overtime_yes", comment: "You are eligible for overtime (non-exempt)")
            } else {
                reviewOvertimeLabel.text = NSLocalizedString("onboard_review_employee_overtime_no", comment: "You are not eligible for overtime (exempt)")
            }
            reviewStateLabel.text = NSLocalizedString("onboard_review_employee_state", comment: "Your employee works in ") + (employmentModel?.employmentUser?.address?.state ?? "West Virginia")
        } else {
            reviewNameLabel.text = NSLocalizedString("onboard_review_name", comment: "You are ") + (profileViewModel!.profileModel.currentUser!.name ?? "John Doe") + NSLocalizedString("onboard_review_employer", comment: ", an employer")
            reviewOtherNameLabel.text = NSLocalizedString("onboard_review_employer_employee", comment: "Your employee's name is ") + (employmentModel?.employmentUser?.name ?? "John Smith")
            reviewWorkweekLabel.text = NSLocalizedString("onboard_review_employer_workweek", comment: "Your workweek starts on ") + (employmentModel?.workWeekStartDay.title ?? "Monday")
            reviewPayTypeLabel.text = NSLocalizedString("onboard_review_employer_frequency", comment: "Your employee is paid ") + (employmentModel?.paymentFrequency.title ?? "Unknown")
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                reviewPayRateLabel.text = NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $") + (String((employmentModel?.hourlyRates![0].value)!)) + "/" + NSLocalizedString("payment_type_hourly", comment: "Hourly")
            }else {
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    reviewPayRateLabel.text = NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $") + String(amount) + "/" + NSLocalizedString("salary_annually", comment: "Annually")
                } else if SalaryType == .monthly {
                    reviewPayRateLabel.text = NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $") + String(amount) + "/" + NSLocalizedString("salary_monthly", comment: "Monthly")
                } else if SalaryType == .weekly {
                    reviewPayRateLabel.text = NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $") + String(amount) + "/" + NSLocalizedString("salary_weekly", comment: "Weekly")
                }
            }
            
            if (employmentModel?.overtimeEligible == true) {
                reviewOvertimeLabel.text = NSLocalizedString("onboard_review_employer_overtime_yes", comment: "Your employee is eligible for overtime (non-exempt)")
            } else {
                reviewOvertimeLabel.text = NSLocalizedString("onboard_review_employer_overtime_no", comment: "Your employee is not eligible for overtime (exempt)")
            }
            reviewStateLabel.text = NSLocalizedString("onboard_review_employer_state", comment: "Your employee works in ") + (employmentModel?.employmentUser?.address?.state ?? "West Virginia")
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
