//
//  SummaryTableViewHeaderView.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/14/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SummaryTableViewHeaderView: UITableViewHeaderFooterView {
    class var nibName: String { return "SummaryTableViewHeaderView" }
    class var reuseIdentifier: String { return "SummaryTableViewHeaderView" }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var section: Int = 0
    
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
        titleLabel.scaleFont(forDataType: .timesheetWorkweekTitle)
    }
    
    func displayInfo() {
        let workWeekStr = "dash_work_week".localized
        let title = "\(workWeekStr) \(section+1): \(workWeekViewModel.title)" // GGG String
        titleLabel.text = title
    }    
}

