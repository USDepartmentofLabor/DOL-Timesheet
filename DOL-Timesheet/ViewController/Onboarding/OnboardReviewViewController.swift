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

    override func saveData() -> Bool  {
        print("OnboardReviewViewController SAVE DATA")
        return true
    }
    
    @IBAction func letsGoPressed(_ sender: Any) {
        employmentModel?.save()
        timeSheetDelegate?.didUpdateEmploymentInfo()
       // delegate?.didUpdateUser()
        dismiss(animated: true, completion: nil)
    }
    
    func boldily(_ start: String, _ middle: String, _ end: String)-> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: start + middle + end)
        let boldRange = NSRange(location: start.count, length: middle.count) // Specify the range of text to be bolded
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16) // Set the bold font
        ]
        attributedString.addAttributes(boldAttributes, range: boldRange)
        return attributedString
    }
    
    func displayInfo() {
        if (userType == .employee) {
            
            reviewNameLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_name", comment: "You are "),
                (profileViewModel!.profileModel.currentUser?.name ?? "John Doe"),
                 NSLocalizedString("onboard_review_employee", comment: ", an employee"))
                
            reviewOtherNameLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_employee_employer", comment: "You work for "),
                (employmentModel?.employmentUser?.name ?? "John Smith"),
                " ")
            
            reviewWorkweekLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_employee_workweek", comment: "Your employer's workweek starts on "),
                (employmentModel?.workWeekStartDay.title ?? "Monday"),
                " ")
            
            reviewPayTypeLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_employee_frequency", comment: "You are paid "),
                (employmentModel?.paymentFrequency.title ?? "Unknown"),
                " ")
            
            var rate = 0.00
            if (employmentModel?.hourlyRates?.count ?? 0 > 0) {
                rate = (employmentModel?.hourlyRates![0].value)!
            }
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                
                reviewPayRateLabel.attributedText = boldily(
                    NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $"),
                    (String(format: "%.2f", rate)) + "/",
                    NSLocalizedString("payment_type_hourly", comment: "Hourly"))
                
            } else {
                
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    
                    reviewPayRateLabel.attributedText = boldily(
                        NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $"),
                        String(format: "%.2f", amount) + "/" + NSLocalizedString("salary_annually", comment: "Annually"),
                        " ")
                    
                } else if SalaryType == .monthly {
                    
                    reviewPayRateLabel.attributedText = boldily(
                        NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $"),
                        String(format: "%.2f", amount) + "/",
                        NSLocalizedString("salary_monthly", comment: "Monthly"))
                        
                } else if SalaryType == .weekly {
                    
                    reviewPayRateLabel.attributedText = boldily(
                        NSLocalizedString("onboard_review_employee_rate", comment: "Your pay rate is $"),
                        String(format: "%.2f", amount) + "/",
                        NSLocalizedString("salary_weekly", comment: "Weekly"))
                }
            }
            
            var exempt1 = NSLocalizedString("onboard_review_employee_overtime_yes1", comment: "You are eligible for overtime (non-exempt)")
            var exempt2 = NSLocalizedString("onboard_review_employee_overtime_yes2", comment: "You are eligible for overtime (non-exempt)")
            if (employmentModel?.overtimeEligible == false) {
                exempt1 = NSLocalizedString("onboard_review_employee_overtime_no1", comment: "You are eligible for overtime (non-exempt)")
                exempt2 = NSLocalizedString("onboard_review_employee_overtime_no2", comment: "You are eligible for overtime (non-exempt)")
            }
            reviewOvertimeLabel.attributedText = boldily(exempt1, exempt2, " ")
                                                         
            let startString =  NSLocalizedString("onboard_review_employee_state", comment: "You work in ")
            
            let stateString = (employmentModel?.employmentUser?.address?.state ?? "West Virginia") + " "
            let minimumString = NSLocalizedString("onboard_review_employee_minimum_wage", comment: "whose state minimum wage is $")
            let wageString = (employmentModel?.minimumWage.stringValue ?? "7.25")
            let endString = "/" + NSLocalizedString("hour", comment: "hour")
            
            let attributedString1 = boldily(startString, stateString, minimumString)
            let attributedString2 = boldily(" ", wageString, endString)
            
            let combinedAttributedString = NSMutableAttributedString()

            combinedAttributedString.append(attributedString1)
            combinedAttributedString.append(attributedString2)
            
            reviewStateLabel.attributedText = combinedAttributedString
                                                      
        } else {
            reviewNameLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_name", comment: "You are "),
                (profileViewModel!.profileModel.currentUser!.name ?? "John Doe"),
                NSLocalizedString("onboard_review_employer", comment: ", an employer"))
            
            reviewOtherNameLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_employer_employee", comment: "Your employee's name is "),
                (employmentModel?.employmentUser?.name ?? "John Smith"),
                " ")
            
            reviewWorkweekLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_employer_workweek", comment: "Your workweek starts on "),
                (employmentModel?.workWeekStartDay.title ?? "Monday"),
                " ")
            
            reviewPayTypeLabel.attributedText = boldily(
                NSLocalizedString("onboard_review_employer_frequency", comment: "Your employee is paid "),
                (employmentModel?.paymentFrequency.title ?? "Unknown"),
                " ")
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                
                reviewPayRateLabel.attributedText = boldily(
                    NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $"),
                    (String((employmentModel?.hourlyRates![0].value)!)) + "/",
                    NSLocalizedString("payment_type_hourly", comment: "Hourly"))
                
            }else {
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    reviewPayRateLabel.attributedText = boldily(
                        NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $"),
                        String(amount) + "/",
                        NSLocalizedString("salary_annually", comment: "Annually"))
                    
                } else if SalaryType == .monthly {
                    reviewPayRateLabel.attributedText = boldily(
                        NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $"),
                        String(amount) + "/",
                        NSLocalizedString("salary_monthly", comment: "Monthly"))
                    
                } else if SalaryType == .weekly {
                    reviewPayRateLabel.attributedText = boldily(
                        NSLocalizedString("onboard_review_employer_rate", comment: "Your employee's pay rate is $"),
                        String(amount) + "/",
                        NSLocalizedString("salary_weekly", comment: "Weekly"))
                }
            }
            
            var exempt1 = NSLocalizedString("onboard_review_employer_overtime_yes1", comment: "You are eligible for overtime (non-exempt)")
            var exempt2 = NSLocalizedString("onboard_review_employer_overtime_yes2", comment: "You are eligible for overtime (non-exempt)")
            if (employmentModel?.overtimeEligible == false) {
                exempt1 = NSLocalizedString("onboard_review_employer_overtime_no1", comment: "You are eligible for overtime (non-exempt)")
                exempt2 = NSLocalizedString("onboard_review_employer_overtime_no2", comment: "You are eligible for overtime (non-exempt)")
            }
            reviewOvertimeLabel.attributedText = boldily(exempt1, exempt2, " ")

//            reviewStateLabel.attributedText = boldily(
//                NSLocalizedString("onboard_review_employer_state", comment: "Your employee works in "),
//                (employmentModel?.employmentUser?.address?.state ?? "West Virginia"),
//                " ")
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
