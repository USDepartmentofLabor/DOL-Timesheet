//
//  EarningDetailsViewCell.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 1/19/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class EarningDetailsViewCell: UITableViewCell {
    
    class var nibName: String { return "EarningDetailsViewCell" }
    class var reuseIdentifier: String { return "EarningDetailsViewCell" }

    @IBOutlet weak var rateName: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    
    var firstItem: Bool = false
    var lastItem: Bool = false
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        contentView.layer.cornerRadius = Style.CORNER_ROUNDING
//        contentView.clipsToBounds = true
    }
    
    public func addborder() {
        topBackgroundView.layer.cornerRadius = firstItem ? 10.0 : 0.0
        topBackgroundView.clipsToBounds = true
        bottomBackgroundView.layer.cornerRadius = lastItem ? 10.0 : 0.0
        bottomBackgroundView.clipsToBounds = true
    }
    
    public func configure(timeLog: TimeLog) {
        
        self.addborder()
    
        if let hourlyTimeLog = timeLog as? HourlyPaymentTimeLog {
            let title = (hourlyTimeLog.value > 0) ? "\(hourlyTimeLog.hourlyRate?.name ?? "") \(NumberFormatter.localisedCurrencyStr(from: hourlyTimeLog.value))" :
            hourlyTimeLog.hourlyRate?.title
            rateName.text = title ?? ""
        } else {
            rateName.text = "Rate"
        }
        
        let hours: Int = timeLog.hoursLogged / 3600
        let minutes: Int = (timeLog.hoursLogged - (hours * 3600)) / 60
        
        totalTime.attributedText = makeBold(input: "\(hours) hrs \(minutes) min")
        totalTime.attributedText = makeBold(input: "\(hours) hrs \(minutes) min")
        totalTime.attributedText = makeBold(input: "\(hours) hrs \(minutes) min")
    }
    
    func makeBold(input: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: input)
        
        // Apply bold style to digits, dollar sign, and period
        for i in 0..<input.count {
            let index = input.index(input.startIndex, offsetBy: i)
            let c = input[index]
            
            if c.isNumber || c == "$" || c == "." {
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize), range: NSRange(location: i, length: 1))
            }
        }
        
        return attributedString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
