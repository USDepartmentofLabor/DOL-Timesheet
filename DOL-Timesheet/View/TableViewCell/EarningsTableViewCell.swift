//
//  UnEmploymentRateTableViewCell.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/1/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit

class EarningsTableViewCell: UITableViewCell {

    class var nibName: String { return "EarningsTableViewCell" }
    class var reuseIdentifier: String { return "EarningsTableViewCell" }
    
    
    @IBOutlet weak var straightTimeStackView: UIStackView!
    @IBOutlet weak var straightTimeEarningsAmountLabel: UILabel!
    
    @IBOutlet weak var straightTimeTitleLabel: UILabel!
    @IBOutlet weak var straightTimeSubTitleLabel: UILabel!
    @IBOutlet weak var straightTimeCalculationsLabel: UILabel!
    
    @IBOutlet weak var regularRateStackView: UIStackView!
    @IBOutlet weak var regularRateView: UIView!
    @IBOutlet weak var regularRateTitleLabel: UILabel!
    @IBOutlet weak var regularRateLabel: UILabel!
    @IBOutlet weak var regularRateCalculationTitleLabel: UILabel!
    @IBOutlet weak var regularRateCalculationsLabel: UILabel!
    @IBOutlet weak var regularRateInfoBtn: InfoButton!
    
    @IBOutlet weak var minimumWageWarning: UILabel!
    @IBOutlet weak var minimumWageTitleLabel: UILabel!
    @IBOutlet weak var minimuWageAmountLabel: UILabel!
    @IBOutlet weak var overtimeView: UIView!
    
    @IBOutlet weak var overtimeStackView: UIStackView!
    
    @IBOutlet weak var overtimeTitleLabel: UILabel!
    @IBOutlet weak var overtimeAmountLabel: UILabel!
    
    @IBOutlet weak var overtimeInfoLabel: UILabel!
    @IBOutlet weak var overtimeCalculationTitleLabel: UILabel!
    @IBOutlet weak var overtimeCalculationLabel: UILabel!
    
    @IBOutlet weak var overtimeInfoBtn: InfoButton!
    
    var workWeekViewModel: WorkWeekViewModel! {
        didSet {
            displayEarnings()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setupView() {
        straightTimeTitleLabel.scaleFont(forDataType: .earningsTitle)
        straightTimeCalculationsLabel.scaleFont(forDataType: .earningsTitle)
        straightTimeSubTitleLabel.scaleFont(forDataType: .earningsValue)
        straightTimeCalculationsLabel.scaleFont(forDataType: .earningsValue)
        
        regularRateTitleLabel.scaleFont(forDataType: .earningsTitle)
        regularRateLabel.scaleFont(forDataType: .earningsTitle)
        regularRateCalculationTitleLabel.scaleFont(forDataType: .earningsValue)
        regularRateCalculationsLabel.scaleFont(forDataType: .earningsValue)
        regularRateInfoBtn.infoType = .regularRate
        
        overtimeTitleLabel.scaleFont(forDataType: .earningsTitle)
        overtimeAmountLabel.scaleFont(forDataType: .earningsTitle)
        overtimeInfoLabel.scaleFont(forDataType: .earningsValue)
        overtimeCalculationTitleLabel.scaleFont(forDataType: .earningsValue)
        overtimeCalculationLabel.scaleFont(forDataType: .earningsValue)

        overtimeInfoBtn.infoType = .overtimePay
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        accessibilityElements = [straightTimeStackView as Any, regularRateStackView as Any, overtimeStackView as Any]
        
        straightTimeStackView.accessibilityElements = [straightTimeTitleLabel as Any, straightTimeEarningsAmountLabel as Any, straightTimeSubTitleLabel as Any, straightTimeCalculationsLabel as Any]
        regularRateStackView.accessibilityElements = [regularRateTitleLabel as Any, regularRateInfoBtn as Any, regularRateLabel as Any, minimumWageTitleLabel as Any, minimuWageAmountLabel as Any, regularRateCalculationTitleLabel as Any, regularRateCalculationsLabel as Any]
        overtimeStackView.accessibilityElements = [overtimeTitleLabel as Any, overtimeInfoBtn as Any, overtimeAmountLabel as Any, overtimeCalculationTitleLabel as Any, overtimeCalculationLabel as Any]
    }
    
    func displayEarnings() {
        straightTimeEarningsAmountLabel.text = workWeekViewModel.straightTimeAmountStr
        
        straightTimeTitleLabel.text = "straight_time_earnings".localized
        straightTimeSubTitleLabel.text = "straight_time_calculation".localized
        
        regularRateTitleLabel.text = "regular_rate_of_pay".localized
        regularRateCalculationTitleLabel.text = "regular_rate_of_pay_equation".localized
        
        overtimeTitleLabel.text = "overtime_pay".localized
        overtimeCalculationTitleLabel.text = "overtime_pay_equation".localized
        
        let straightTimeCalculationsStr = workWeekViewModel.straightTimeCalculationsStr
        straightTimeCalculationsLabel.text = straightTimeCalculationsStr
        if straightTimeCalculationsStr.isEmpty {
            straightTimeSubTitleLabel.text = ""
        }
        else {
            straightTimeSubTitleLabel.text = "straight_time_calculation".localized
        }
        if workWeekViewModel.isBelowMinimumWage {
            minimumWageWarning.text = "err_title_minimum_wage".localized
        }
        else {
            minimumWageWarning.text = ""
        }
        regularRateLabel.text = workWeekViewModel.regularRateStr
        regularRateCalculationsLabel.text = workWeekViewModel.regularRateCalculationStr

        if workWeekViewModel.overtimeEligible {
            overtimeView.isHidden = false
            overtimeAmountLabel.text = workWeekViewModel.overtimeAmountStr
            overtimeCalculationLabel.text = workWeekViewModel.overtimeCalculationStr
            
            overtimeInfoLabel.text = workWeekViewModel.overtimePaymentTimeInfo
            overtimeTitleLabel.isHidden = false
            overtimeAmountLabel.isHidden = false
            overtimeCalculationTitleLabel.isHidden = false
            overtimeInfoLabel.isHidden = false
            overtimeInfoBtn.isHidden = false
            overtimeCalculationLabel.isHidden = false
        }
        else {
            overtimeView.isHidden = true
            overtimeTitleLabel.isHidden = true
            overtimeAmountLabel.isHidden = true
            overtimeCalculationTitleLabel.isHidden = true
            overtimeInfoLabel.isHidden = true
            overtimeInfoBtn.isHidden = true
            overtimeCalculationLabel.isHidden = true
        }
    }
}

