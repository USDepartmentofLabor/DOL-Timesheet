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
                title = "employee".localized
            case .pay:
                title = "info_pay_title".localized
            case .overtime:
                title = "info_overtime_title".localized
            case .minimumWage:
                title = "info_minimum_wage_title".localized
            case .nonExempt:
                title = "info_non_exempt_title".localized
            case .workWeek:
                title = "info_work_week_title".localized
            case .breakTime:
                title = "info_break_time_title".localized
            }
            
            return title
        }
    
        func desc(for profileModel: ProfileModel) -> NSAttributedString? {
            let desc: String
            switch self {
            case .profileUser:
                desc = "info_employee".localized
            case .pay:
                desc = profileModel.isEmployer ? "info_employer_payment_type".localized :
                "info_employee_payment_type".localized
            case .overtime:
                desc = "info_glossary_overtime".localized
            case .minimumWage:
                desc = "info_glossary_minimum_wage".localized
            case .nonExempt:
                desc = "info_overtime_eligible".localized
            case .workWeek:
                desc = "info_glossary_work_week".localized
            case .breakTime:
                desc = "info_break_time".localized
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
