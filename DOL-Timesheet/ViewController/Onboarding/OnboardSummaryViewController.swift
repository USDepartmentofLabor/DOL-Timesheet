//
//  OnboardReviewViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 9/10/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class OnboardSummaryViewController: OnboardBaseViewController {

    @IBOutlet weak var displayLogo: UIImageView!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    
    @IBOutlet weak var reviewNameTitleLabel: UILabel!
    @IBOutlet weak var reviewNameLabel: UILabel!
    
    @IBOutlet weak var reviewOtherNameTitleLabel: UILabel!
    @IBOutlet weak var reviewOtherNameLabel: UILabel!
    
    @IBOutlet weak var reviewWorkweekTitleLabel: UILabel!
    @IBOutlet weak var reviewWorkweekLabel: UILabel!
    
    @IBOutlet weak var reviewPayTypeTitleLabel: UILabel!
    @IBOutlet weak var reviewPayTypeLabel: UILabel!
    
    @IBOutlet weak var reviewStartDateTitleLabel: UILabel!
    @IBOutlet weak var reviewStartDateLabel: UILabel!
    
    @IBOutlet weak var reviewPayRateTitleLabel: UILabel!
    @IBOutlet weak var reviewPayRateLabel: UILabel!
    
    @IBOutlet weak var reviewOvertimeTitleLabel: UILabel!
    @IBOutlet weak var reviewOvertimeLabel: UILabel!
    
    @IBOutlet weak var reviewStateTitleLabel: UILabel!
    @IBOutlet weak var reviewStateLabel: UILabel!
    
    @IBOutlet weak var reviewConfirmButton: UIButton!
    
    @IBOutlet weak var reviewNote: UILabel!
    
    @IBOutlet weak var nextButton: NavigationButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        canMoveForward = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        displayInfo()
    }
    
    override func setupView() {
//        title = NSLocalizedString("introduction", comment: "Introduction")
//        label1.scaleFont(forDataType: .introductionBoldText)
//        label2.scaleFont(forDataType: .introductionText)
        
        reviewTitleLabel.text = "summary".localized
        
        reviewNameTitleLabel.text = "onboarding_name_nickname".localized
        reviewWorkweekTitleLabel.text = "onboarding_pay_week".localized
        reviewPayTypeTitleLabel.text = "pay_frequency".localized
        reviewStartDateTitleLabel.text = "employer_first_pay_period".localized
        reviewPayRateTitleLabel.text = "pay_rate".localized
        reviewOvertimeTitleLabel.text = "onboarding_employee_eligible_overtime".localized
        reviewStateTitleLabel.text = "onboarding_employee_state_min_wage".localized
        
        reviewConfirmButton.setTitle("onboard_review_button".localized, for: .normal)
        reviewNote.text = "onboard_review_note".localized
        
        if userType != .employee {
            reviewPayTypeTitleLabel.text = "employee_pay_frequency".localized
            reviewPayRateTitleLabel.text = "employee_pay_rate".localized
            reviewOvertimeTitleLabel.text = "onboarding_employer_eligible_overtime".localized
            reviewStateTitleLabel.text = "onboarding_employer_state_min_wage".localized
            
            reviewStartDateTitleLabel.text = "onboarding_first_day_pay".localized



        }
        
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
    
    func boldily(_ plain: String)-> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: plain)
        let boldRange = NSRange(location: 0, length: plain.count) // Specify the range of text to be bolded
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16) // Set the bold font
        ]
        attributedString.addAttributes(boldAttributes, range: boldRange)
        return attributedString
    }
    
    func displayInfo() {
        if (userType == .employee) {
            
            reviewOtherNameTitleLabel.text = "employer".localized
            reviewStateTitleLabel.isHidden = false
            
            reviewNameLabel.attributedText = boldily(
                (profileViewModel!.profileModel.currentUser?.name ?? " ")
            )
                
            reviewOtherNameLabel.attributedText = boldily(
                (employmentModel?.employmentUser?.name ?? " ")
            )
            
            reviewWorkweekLabel.attributedText = boldily(
                (employmentModel?.workWeekStartDay.title ?? " ")
            )
            
            reviewPayTypeLabel.attributedText = boldily(
                (employmentModel?.paymentFrequency.title ?? " ")
            )
            
            reviewStartDateLabel.attributedText = boldily(
                (formatDateToString((employmentModel?.employmentInfo.startDate)!))
            )
                        
            var rate = 0.00
            if (employmentModel?.hourlyRates?.count ?? 0 > 0) {
                rate = (employmentModel?.hourlyRates![0].value)!
            }
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                
                reviewPayRateLabel.attributedText = boldily(
                    "$" + (String(format: "%.2f", rate)) + "/" + "payment_hour".localized
                )
                
            } else {
                
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    
                    reviewPayRateLabel.attributedText = boldily(
                        "$" + String(format: "%.2f", amount) + "/" + "salary_annually".localized
                    )
                    
                } else if SalaryType == .monthly {
                    
                    reviewPayRateLabel.attributedText = boldily(
                        "$" + String(format: "%.2f", amount) + "/" + "salary_monthly".localized
                    )
                        
                } else if SalaryType == .weekly {
                    
                    reviewPayRateLabel.attributedText = boldily(
                        "$" + String(format: "%.2f", amount) + "/" + "salary_weekly".localized
                    )
                }
            }
            
            var exempt = "onboard_review_overtime_yes".localized
            if (employmentModel?.overtimeEligible == false) {
                exempt = "onboard_review_overtime_no".localized
            }
            reviewOvertimeLabel.attributedText = boldily(exempt)
                                                         
            
                                                      
        } else {
            
            reviewOtherNameTitleLabel.text = "employee".localized
            
            reviewNameLabel.attributedText = boldily(
                (profileViewModel!.profileModel.currentUser!.name ?? " ")
            )
            
            reviewOtherNameLabel.attributedText = boldily(
                (employmentModel?.employmentUser?.name ?? " ")
            )
            
            reviewWorkweekLabel.attributedText = boldily(
                (employmentModel?.workWeekStartDay.title ?? " ")
            )
            
            reviewPayTypeLabel.attributedText = boldily(
                (employmentModel?.paymentFrequency.title ?? " ")
            )
            
            reviewStartDateLabel.attributedText = boldily(
                (formatDateToString((employmentModel?.employmentInfo.startDate)!))
            )
            
            if employmentModel?.employmentInfo.paymentType == .hourly {
                
                var rate = 0.00
                if (employmentModel?.hourlyRates?.count ?? 0 > 0) {
                    rate = (employmentModel?.hourlyRates![0].value)!
                }
                
                reviewPayRateLabel.attributedText = boldily(
                    "$" + (String(format: "%.2f", rate)) + "/" + "payment_type_hourly".localized
                )
                
            }else {
                let SalaryType = employmentModel?.employmentInfo.salary?.salaryType
                let salary = employmentModel?.employmentInfo.salary
                let amount = salary?.value ?? 10.00
                
                
                if SalaryType == .annually {
                    reviewPayRateLabel.attributedText = boldily(
                        "$" + String(format: "%.2f", amount) + "/" + "salary_annually".localized
                    )
                    
                } else if SalaryType == .monthly {
                    reviewPayRateLabel.attributedText = boldily(
                        "$" + String(format: "%.2f", amount) + "/" + "salary_monthly".localized
                    )
                    
                } else if SalaryType == .weekly {
                    reviewPayRateLabel.attributedText = boldily(
                        "$" + String(format: "%.2f", amount) + "/" + "salary_weekly".localized)
                }
            }
            
            var exempt = "onboard_review_overtime_yes".localized
            if (employmentModel?.overtimeEligible == false) {
                exempt = "onboard_review_overtime_no".localized
            }
            reviewOvertimeLabel.attributedText = boldily(exempt)
            
            let stateString = (employmentModel?.employmentUser?.address?.state ?? "West Virginia") + " "
            let wageString = (employmentModel?.minimumWage.stringValue ?? "7.25")
            let endString = "/" + "hour".localized
            
            let stateWageString = stateString + " ($" + wageString + endString + ")"
            
            let attributedString = boldily(stateWageString)
            
            reviewStateLabel.attributedText = attributedString
            
//            reviewStateLabel.attributedText = boldily(
//                NSLocalizedString("onboard_review_employer_state", comment: "Your employee works in "),
//                (employmentModel?.employmentUser?.address?.state ?? "West Virginia"),
//                " ")
        }
//        nextButton.setTitle(NSLocalizedString("next", comment: "Next"), for: .normal)
    }
    
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setupProfile",
//            let setupVC = segue.destination as? SetupProfileViewController {
//            setupVC.delegate = delegate
//        }
//    }
}
