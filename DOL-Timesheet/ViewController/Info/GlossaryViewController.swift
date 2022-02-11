//
//  GlossaryViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class GlossaryViewController: UIViewController {

    enum GloassaryItem: CaseIterable {
        case profileUser
        case pay
        case overtime
        case minimumWage
        case nonExempt
        case workWeek
        case breakTime
        
        func title(for profileModel: ProfileModel) -> String {
            let title: String
            switch self {
            case .profileUser:
                title = NSLocalizedString("employee", comment: "Employee")
            case .pay:
                title = NSLocalizedString("info_pay_title", comment: "Pay")
            case .overtime:
                title = NSLocalizedString("info_overtime_title", comment: "Overtime")
            case .minimumWage:
                title = NSLocalizedString("info_minimum_wage_title", comment: "Minimum Wage")
            case .nonExempt:
                title = NSLocalizedString("info_non_exempt_title", comment: "Non-exempt")
            case .workWeek:
                title = NSLocalizedString("info_work_week_title", comment: "Work Week")
            case .breakTime:
                title = NSLocalizedString("info_break_time_title", comment: "Break Time")
            }
            
            return title
        }
    
        func desc(for profileModel: ProfileModel) -> NSAttributedString? {
            let desc: String
            switch self {
            case .profileUser:
                desc = NSLocalizedString("info_employee", comment: "Employee Info")
            case .pay:
                desc = profileModel.isEmployer ? NSLocalizedString("info_employer_payment_type", comment: "Pay") :
                NSLocalizedString("info_employee_payment_type", comment: "Pay")
            case .overtime:
                desc = NSLocalizedString("info_glossary_overtime", comment: "Overtime")
            case .minimumWage:
                desc = NSLocalizedString("info_glossary_minimum_wage", comment: "Minimum Wage")
            case .nonExempt:
                desc = NSLocalizedString("info_overtime_eligible", comment: "Non-exempt")
            case .workWeek:
                desc = NSLocalizedString("info_glossary_work_week", comment: "Work Week")
            case .breakTime:
                desc = NSLocalizedString("info_break_time", comment: "Break Time")
            }

            let htmlAttributedStr = NSMutableAttributedString(withLocalizedHTMLString: desc)
            htmlAttributedStr?.addAttribute(NSMutableAttributedString.Key.font, value: Style.scaledFont(forDataType: .glossaryText), range: NSRange(location: 0, length: htmlAttributedStr?.string.count ?? 0))

            if #available(iOS 13.0, *) {
                htmlAttributedStr?.addAttribute(NSMutableAttributedString.Key.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: htmlAttributedStr?.string.count ?? 0))
            }
            
            return htmlAttributedStr
        }
    }

    var profileModel = ProfileModel(context: CoreDataManager.shared().viewManagedContext)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
    }
}


extension GlossaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GloassaryItem.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GlossaryTableViewCell.reuseIdentifier) as! GlossaryTableViewCell
        
        let section = GloassaryItem.allCases[indexPath.row]
        cell.titleLabel?.text = section.title(for: profileModel)
        cell.descLabel.attributedText = section.desc(for: profileModel)
        
        return cell
    }
}
