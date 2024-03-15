//
//  EarningsTableViewHeaderView.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/14/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol EarningsHeaderViewDelegate: class {
    func sectionHeader(_ sectionHeader: EarningsTableViewHeaderView, toggleExpand section:Int)
}

class EarningsTableViewHeaderView: UITableViewHeaderFooterView {
    class var nibName: String { return "EarningsTableViewHeaderView" }
    class var reuseIdentifier: String { return "EarningsTableViewHeaderView" }
    
    @IBOutlet weak var expandCollapseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var section: Int = 0
    
    weak var delegate: EarningsHeaderViewDelegate?
    var workWeekViewModel: WorkWeekViewModel! {
        didSet {
            displayInfo()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }
    
    func setupView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleOpen(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer)
        
        titleLabel.scaleFont(forDataType: .timesheetWorkweekTitle)
        amountLabel.scaleFont(forDataType: .timesheetWorkweekTitle)
    }
    
    @objc private func toggleOpen(_ sender: UITapGestureRecognizer) {
        toggleExpand(withUserAction: true)
    }
    
    func displayInfo() {
        let workWeekStr = "work_week".localized
        let title = "\(workWeekStr)\(section+1): \(workWeekViewModel.title)"
        titleLabel.text = title
        
        let paymentFrequency = workWeekViewModel.employmentInfo.payFrequency
        if paymentFrequency == .weekly || paymentFrequency == .biWeekly {
            amountLabel.text = workWeekViewModel.totalEarningsStr
        }
        else {
            amountLabel.text = ""
        }
        
        collapseSection(collapse: workWeekViewModel.isCollapsed)

    }
    
    func toggleExpand(withUserAction userAction: Bool) {
        // if this was a user action, send the delegate the appropriate message
        if (userAction) {
            delegate?.sectionHeader(self, toggleExpand: section)
        }
    }
    
    func collapseSection(collapse: Bool) {
        if Util.isVoiceOverRunning {
            expandCollapseImageView.image = nil
            return
        }
        
        if collapse {
            expandCollapseImageView.image = #imageLiteral(resourceName: "collape")
        }
        else {
            expandCollapseImageView.image = #imageLiteral(resourceName: "expand")
        }
    }
}

