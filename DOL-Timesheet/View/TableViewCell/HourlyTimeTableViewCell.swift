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
            breakHoursLabel.accessibilityLabel = NSLocalizedString("total_break", comment: "Total Break") + breakHours
        }
    }

    var workedHours: String = "" {
        didSet {
            workedHoursLabel.text = workedHours
            workedHoursLabel.accessibilityLabel = NSLocalizedString("total_worked", comment: "Total Worked") + workedHours
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
        dayLabel.accessibilityHint = NSLocalizedString("click_enter_time", comment: "Tap to Enter time")
        
        accessibilityElements = [dayLabel as Any, workedHoursLabel as Any, breakHoursLabel as Any]
    }
    
    var currentDate: Date? {
        didSet {
            dayLabel.text = "\(currentDate?.formattedWeekday ?? "")\n\(currentDate?.formattedDate ?? "")"
        }
    }
}
