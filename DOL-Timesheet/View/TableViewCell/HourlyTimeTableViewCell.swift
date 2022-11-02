//
//  HourlyTimeTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HourlyTimeTableViewCell: UITableViewCell {

    class var reuseIdentifier: String { return "HourlyTimeTableViewCell" }

    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var workedHoursLabel: UILabel!
    @IBOutlet weak var breakHoursLabel: UILabel!

    var breakHours: String = "" {
        didSet {
            breakHoursLabel.text = breakHours
            breakHoursLabel.accessibilityLabel = "total_break".localized + breakHours
        }
    }

    var workedHours: String = "" {
        didSet {
            workedHoursLabel.text = workedHours
            workedHoursLabel.accessibilityLabel = "total_worked".localized + workedHours
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
        dayLabel.scaleFont(forDataType: .timesheetTimeTable)
        workedHoursLabel.scaleFont(forDataType: .timesheetTimeTable)
        breakHoursLabel.scaleFont(forDataType: .timesheetTimeTable)
        setupAccessibility()
    }

    func setupAccessibility() {
        isAccessibilityElement = false
        dayLabel.accessibilityTraits = .button
        dayLabel.accessibilityHint = "click_enter_time".localized
        
        accessibilityElements = [dayLabel as Any, workedHoursLabel as Any, breakHoursLabel as Any]
    }
    
    var currentDate: Date? {
        didSet {
            dayLabel.text = "\(currentDate?.formattedWeekday ?? "")\n\(currentDate?.formattedDate ?? "")"
        }
    }
}
