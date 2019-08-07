//
//  EnterHourlyTimeTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol EnterTimeTableCellProtocol: class {
    func remove(cell: UITableViewCell, timeLog: TimeLog)
    func showPicker(cell: UITableViewCell, sender: Any?, pickerVC: UIViewController)
    func isValid(startTime: Date, for timeLog: TimeLog?) -> Bool
    func isValid(endTime: Date, for timeLog: TimeLog?) -> Bool
    func isValid(breakTime: Double, for timeLog: TimeLog?) -> Bool
    func showAlert(cell: UITableViewCell, sender: Any?, alertController: UIAlertController)

    func contentDidChange(cell: EnterHourlyTimeTableViewCell)
}

class EnterHourlyTimeTableViewCell: UITableViewCell {

    class var reuseIdentifier: String { return "EnterHourlyTimeTableViewCell" }

    var timeLog: TimeLog? {
        didSet {
            displayInfo()
        }
    }
    
    
    @IBOutlet weak var enterTimeStackView: UIStackView!
    @IBOutlet weak var startTimeView: DropDownView!
    @IBOutlet weak var endTimeView: DropDownView!
    @IBOutlet weak var breakTimeView: DropDownView!
    @IBOutlet weak var hourlyRateView: DropDownView!

    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var commentsTitleLabel: UILabel!
    
    weak var delegate: EnterTimeTableCellProtocol?
    weak var textViewDelegate: UITextViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupView() {
        commentsTextView.addBorder()
        commentsTextView.delegate = self
        startTimeView.titleLabel.scaleFont(forDataType: .enterTimeValue)
        endTimeView.titleLabel.scaleFont(forDataType: .enterTimeValue)
        breakTimeView.titleLabel.scaleFont(forDataType: .enterTimeValue)
        if hourlyRateView != nil {
            hourlyRateView.titleLabel.scaleFont(forDataType: .enterTimeValue)
        }
        commentsTitleLabel.scaleFont(forDataType: .columnHeader)
        commentsTextView.scaleFont(forDataType: .enterCommentsValue)
        
        let startTimeTapGesture = UITapGestureRecognizer(target: self, action: #selector(startTimeClick(_:)))
        startTimeTapGesture.cancelsTouchesInView = false
        startTimeView.addGestureRecognizer(startTimeTapGesture)

        let endTimeTapGesture = UITapGestureRecognizer(target: self, action: #selector(endTimeClick(_:)))
        endTimeTapGesture.cancelsTouchesInView = false
        endTimeView.addGestureRecognizer(endTimeTapGesture)

        let breakTimeTapGesture = UITapGestureRecognizer(target: self, action: #selector(breakTimeClick(_:)))
        breakTimeTapGesture.cancelsTouchesInView = false
        breakTimeView.addGestureRecognizer(breakTimeTapGesture)

        let rateTapGesture = UITapGestureRecognizer(target: self, action: #selector(rateClick(_:)))
        rateTapGesture.cancelsTouchesInView = false
        hourlyRateView.addGestureRecognizer(rateTapGesture)

        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        startTimeView.accessibilityHint = NSLocalizedString("start_time_hint", comment: "Tap To Select Start Time")
        endTimeView.accessibilityHint = NSLocalizedString("end_time_hint", comment: "Tap To Select End Time")
        breakTimeView.accessibilityHint = NSLocalizedString("break_time_hint", comment: "Tap To Select Break Time")
        hourlyRateView.accessibilityHint = NSLocalizedString("hourly_rate_hint", comment: "Tap To Select Houlry Rate")
        
        commentsTextView.accessibilityHint = NSLocalizedString("enter_comments", comment: "Enter Comments")
        accessibilityElements = [startTimeView as Any, endTimeView as Any, breakTimeView as Any, hourlyRateView as Any, commentsTitleLabel as Any, commentsTextView as Any]
    }
    
    func displayInfo() {
        
        let startTime = timeLog?.startTime?.formattedTime
        startTimeView.title = startTime ?? ""
        
        let endTime = timeLog?.endTime?.formattedTime
        endTimeView.title = endTime ?? ""

        if let hourlyTimeLog = timeLog as? HourlyPaymentTimeLog {
            
            let title = (hourlyTimeLog.value > 0) ? "\(hourlyTimeLog.hourlyRate?.name ?? "") \(NumberFormatter.localisedCurrencyStr(from: hourlyTimeLog.value))" :
                hourlyTimeLog.hourlyRate?.title
            hourlyRateView.title = title ?? ""
        }
        else if hourlyRateView != nil {
            enterTimeStackView.removeArrangedSubview(hourlyRateView)
            hourlyRateView.removeFromSuperview()
            accessibilityElements = [startTimeView as Any, endTimeView as Any, breakTimeView as Any, commentsTitleLabel as Any, commentsTextView as Any]
        }
        
        displayBreakTime(timeInSeconds: timeLog?.breakTime ?? 0)
        commentsTextView.text = timeLog?.comment
    }
    
    
    @IBAction func startTimeClick(_ sender: Any) {
        showPicker(mode: .time, sender: startTimeView as Any, date: timeLog?.startTime)
    }
    
    @IBAction func endTimeClick(_ sender: Any) {
        showPicker(mode: .time, sender: endTimeView as Any, date: timeLog?.endTime)
    }
    
    @IBAction func breakTimeClick(_ sender: Any) {
        showPicker(mode: .countDownTimer, sender: breakTimeView as Any, countdownDuration: timeLog?.breakTime ?? 0)
    }
    
    func showPicker(mode: UIDatePicker.Mode, sender: Any, date: Date? = nil, countdownDuration: TimeInterval = 0) {
        let timePickerVC = TimePickerViewController.instantiateFromStoryboard()
        timePickerVC.delegate = self
        timePickerVC.sourceView = (sender as! UIView)
        timePickerVC.pickerMode = mode
        if mode == .countDownTimer {
            timePickerVC.countdownDuration = countdownDuration
        }
        else if mode == .time {
            if let date = date {
                timePickerVC.currentDate = date
            }
            else if let logDate = timeLog?.dateLog?.date {
                var dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: logDate)
                let timeComponent = Calendar.current.dateComponents([.hour, .minute], from: Date())
                dateComponent.hour = timeComponent.hour
                dateComponent.minute = timeComponent.minute
                timePickerVC.currentDate = Calendar.current.date(from: dateComponent)
            }
        }
        
        delegate?.showPicker(cell: self, sender: sender, pickerVC: timePickerVC)
    }
    
    @IBAction func rateClick(_ sender: Any) {
        guard  let options =  timeLog?.dateLog?.employmentInfo?.sortedRates() else {
            return
        }
        
        let optionsVC = OptionsListViewController(options: options,
                                           title: "")
        optionsVC.didSelect = { [weak self] (popVC: UIViewController, hourlyRate: HourlyRate?) in
            guard let strongSelf = self else { return }
            if let hourlyRate = hourlyRate, let hourlyTimeLog = strongSelf.timeLog as? HourlyPaymentTimeLog {
                strongSelf.hourlyRateView.title = hourlyRate.title
                strongSelf.delegate?.contentDidChange(cell: strongSelf)
                hourlyTimeLog.hourlyRate = hourlyRate
                hourlyTimeLog.value = hourlyRate.value
            }
            popVC.dismiss(animated: true, completion: nil)
        }
        
        delegate?.showPicker(cell: self, sender: hourlyRateView, pickerVC: optionsVC)
    }

    
    @IBAction func removeClick(_ sender: Any) {
        if let timeLog = timeLog {
            delegate?.remove(cell: self, timeLog: timeLog)
        }
    }
}


extension EnterHourlyTimeTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidEndEditing?(textView)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        timeLog?.comment = commentsTextView.text
    }
}

extension EnterHourlyTimeTableViewCell: TimePickerProtocol {
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker) {
        if sourceView == startTimeView {
            let time = datePicker.date.removeSeconds()
            if delegate?.isValid(startTime: time, for: timeLog) ?? true {
                timeLog?.startTime = time
                startTimeView.title = time.formattedTime
            }
        }
        else if sourceView == endTimeView {
            var time = datePicker.date.removeSeconds()
            
            if time.isMidnight() {
                time = time.addDays(days: 1)
            }
            
            if delegate?.isValid(endTime: time, for: timeLog) ?? true {
                timeLog?.endTime = time
                endTimeView.title = time.formattedTime
            }
        }
        else if sourceView == breakTimeView,
            delegate?.isValid(breakTime: datePicker.countDownDuration, for: timeLog) ?? true {
            updateBreakTime(duration: datePicker.countDownDuration)
        }
        delegate?.contentDidChange(cell: self)
    }

    func updateBreakTime(duration: TimeInterval) {
        if duration <= EmploymentModel.ALLOWED_BREAK_SECONDS {
            let title = NSLocalizedString("info_break_time_title", comment: "Break Time")
            let message = NSLocalizedString("break_time_warning", comment: "Break Time is less that minutes")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { [weak self] (action) in
                guard let strongSelf = self else {return}
                strongSelf.timeLog?.breakTime = duration
                strongSelf.displayBreakTime(timeInSeconds: duration)
            }))
            delegate?.showAlert(cell: self, sender: breakTimeView, alertController: alertController)
        }
        else {
            timeLog?.breakTime = duration
            displayBreakTime(timeInSeconds: duration)
        }
    }
    
    func displayBreakTime(timeInSeconds: Double?) {
        guard let timeInSeconds = timeInSeconds else {
            breakTimeView.title = "0 Min"
            return
        }
        
        let timeStr: String = Date.secondsToHoursMinutes(seconds: timeInSeconds)
        breakTimeView.title = timeStr
    }
}
