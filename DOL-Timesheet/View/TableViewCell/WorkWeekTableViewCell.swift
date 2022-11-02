//
//  WorkWeekTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/25/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol WorkWeekCellDelegate: class {
    func select(weekday: Weekday?)
}

class WorkWeekTableViewCell: UITableViewCell {
    class var nibName: String { return "WorkWeekTableViewCell" }
    class var reuseIdentifier: String { return "WorkWeekTableViewCell" }

    @IBOutlet weak var workWeekBtn: UIButton!
    var weekday: Weekday?  {
        didSet {
            var title: String = "work_week_dont_know".localized
            if let weekday = weekday {
                title = weekday.title
            }
            
            workWeekBtn.setTitle(title, for: .normal)
        }
    }

    weak var delegate: WorkWeekCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnClick(_ sender: Any) {
        delegate?.select(weekday: weekday)
    }
}
