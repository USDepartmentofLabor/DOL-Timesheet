//
//  InfoPopupViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/16/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol InfoPopupDelegate: class {
    func handle(url: URL, popupController: InfoPopupViewController?)
}

enum Info: String {
    case employee_Employer
    case employer
    case employee
    case workWeek               // On What day does your work Week Begin
    case employee_paymentType
    case employer_paymentType
    case employee_hourlyPayRate
    case employer_hourlyPayRate
    case salary                 // What is your Salary?
    case overtimeEligible
    case minimumWage
    case employee_workweek
    case employer_workweek
    case employee_paymentFrequency
    case employer_paymentFrequency
    case employee_salary
    case employer_salary
    case overtime
    case overtimePay
    case breakTime
    case unknown
    
    var title: String {
        let title: String
        switch self {
        case .employee_Employer:
            title = NSLocalizedString("info_employee_employer", comment: "Select Employee or Employer")
        case .employer:
            title = NSLocalizedString("info_employer", comment: "Who is employer")
        case .employee:
            title = NSLocalizedString("info_employee", comment: "Who is employee")
        case .workWeek:
            title = "Work Week"
        case .employee_paymentType:
            title = NSLocalizedString("info_employee_payment_type", comment: "What is your payment type")
        case .employer_paymentType:
            title = NSLocalizedString("info_employer_payment_type", comment: "What is your employees payment type")
        case .employee_hourlyPayRate:
            title = NSLocalizedString("info_employee_hourly_pay_rate", comment: "What is your hourly rate")
        case .employer_hourlyPayRate:
            title = NSLocalizedString("info_employer_hourly_pay_rate", comment: "What is your hourly rate")
        case .salary:
            title = "Salary"
        case .overtimeEligible:
            title = NSLocalizedString("info_overtime_eligible", comment: "Are you overtime eligible")
        case .minimumWage:
            title = NSLocalizedString("info_minimum_wage", comment: "Minimum Wage")
        case .employee_workweek:
            title = NSLocalizedString("info_employee_workweek", comment: "Work Week")
        case .employer_workweek:
            title = NSLocalizedString("info_employer_workweek", comment: "Work Week")
        case .employee_paymentFrequency:
            title = NSLocalizedString("info_employee_payment_frequency", comment: "Payment Frequency")
        case .employer_paymentFrequency:
            title = NSLocalizedString("info_employer_payment_frequency", comment: "Payment Frequency")
        case .employee_salary:
            title = NSLocalizedString("info_employee_salary", comment: "Salary")
        case .employer_salary:
            title = NSLocalizedString("info_employer_salary", comment: "Salary")
        case .overtime:
            title = NSLocalizedString("info_overtime", comment: "Overtime")
        case .overtimePay:
            title = NSLocalizedString("info_overtime_pay", comment: "Overtime Pay")
        case .breakTime:
            title = NSLocalizedString("info_break_time", comment: "Break Time")
        case .unknown:
            title = ""
        }
        return title
    }
}

class InfoPopupViewController: UIViewController {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoTextView: UITextView!
    var infoValue: Info?
    weak var delegate: InfoPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let currentSize =  view.bounds.size
//        let infosize = infoTextView.intrinsicContentSize
        preferredContentSize = contentView.bounds.size
    }

    func setupView() {
//        infoLabel.scaleFont(forDataType: .aboutText)
        infoTextView.delegate = self
        if let title = infoValue?.title {
            let htmlAttributedStr = NSMutableAttributedString(withLocalizedHTMLString: title)
            htmlAttributedStr?.addAttribute(NSMutableAttributedString.Key.font, value: Style.scaledFont(forDataType: .aboutText), range: NSRange(location: 0, length: htmlAttributedStr?.string.count ?? 0))

            infoTextView.attributedText = htmlAttributedStr
        }
        else {
           infoTextView.text = ""
        }
    }
}

extension InfoPopupViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.handle(url: URL, popupController: self)
        }
        
        return false
    }
}