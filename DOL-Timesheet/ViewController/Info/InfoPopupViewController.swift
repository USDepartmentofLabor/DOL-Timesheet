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
    case regularRate
    case overtimePay
    case endTime
    case breakTime
    case importDBEmployee
    case round_updown
    case dont_round_updown
    case state
    case unknown
    
    var title: String {
        let title: String
        
//        let titleString = NSMutableAttributedString(string: "fsla_info".localized)
//        let linkedText = "wage_and_hour_division".localized
//        _ = titleString.setAsLink(textToFind: linkedText, linkURL: "wage_and_hour_division_link".localized)
//
//        titleString.addAttribute(.font, value: Style.scaledFont(forDataType: .aboutText), range: NSRange(location: 0, length: fslaInfoStr.length))
//        title = titleString
        
        switch self {
        case .employee_Employer:
            title = "info_employee_employer".localized
        case .employer:
            title = "info_employer".localized
        case .employee:
            title = "info_employee".localized
        case .workWeek:
            title = "work_week".localized
        case .employee_paymentType:
            title = "info_employee_payment_type".localized
        case .employer_paymentType:
            title = "info_employer_payment_type".localized
        case .employee_hourlyPayRate:
            title = "info_employee_hourly_pay_rate".localized
        case .employer_hourlyPayRate:
            title = "info_employer_hourly_pay_rate".localized
        case .salary:
            title = "payment_type_salary".localized
        case .overtimeEligible:
            title = "info_overtime_eligible".localized
        case .minimumWage:
            title = "info_minimum_wage".localized
        case .employee_workweek:
            title = "info_employee_workweek".localized
        case .employer_workweek:
            title = "info_employer_workweek".localized
        case .employee_paymentFrequency:
            title = "info_employee_payment_frequency".localized
        case .employer_paymentFrequency:
            title = "info_employer_payment_frequency".localized
        case .employee_salary:
            title = "info_employee_salary".localized
        case .employer_salary:
            title = "info_employer_salary".localized
        case .overtime:
            title = "info_overtime".localized
        case .regularRate:
            title = "info_regular_rate".localized
        case .overtimePay:
            title = "info_overtime_pay".localized
        case .endTime:
            title = "info_end_time".localized
        case .breakTime:
            title = "info_break_time".localized
        case .importDBEmployee:
            title = NSLocalizedString("info_import_employee", comment: "Import old employee database")
        case .round_updown:
            title = NSLocalizedString("info_round_up_down_text", comment: "Round UpDown Time")
        case .dont_round_updown:
            title = NSLocalizedString("info_dont_round_up_down_text", comment: "Dont Round UpDown Time")
        case .state:
            title = "info_state".localized
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
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var completionHandler: (()->Void)?
    
    var infoValue: Info?
    weak var delegate: InfoPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize =  CGSize(width: contentView.bounds.size.width,
                                       height: contentView.bounds.size.height + 37)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        preferredContentSize =  CGSize(width: contentView.bounds.size.width,
                                       height: contentView.bounds.size.height + 37)
    }
    
    func setupView() {
        infoTextView.textContainerInset = UIEdgeInsets.zero
        infoTextView.textContainer.lineFragmentPadding = 0

        infoTextView.delegate = self
        if let title = infoValue?.title {
            let htmlAttributedStr = NSMutableAttributedString(withLocalizedHTMLString: title)
            htmlAttributedStr?.addAttribute(NSMutableAttributedString.Key.font, value: Style.scaledFont(forDataType: .aboutText), range: NSRange(location: 0, length: htmlAttributedStr?.string.count ?? 0))

            if #available(iOS 13.0, *) {
                htmlAttributedStr?.addAttribute(NSMutableAttributedString.Key.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: htmlAttributedStr?.string.count ?? 0))
            } 
            infoTextView.attributedText = htmlAttributedStr
        }
        else {
           infoTextView.text = ""
        }
        setupAccessibility()
    }
    
    @IBAction func closeClick(_ sender: Any) {
        dismiss(animated: false, completion: completionHandler)
    }
    
    func setupAccessibility() {
        closeBtn.accessibilityLabel = "close".localized
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
