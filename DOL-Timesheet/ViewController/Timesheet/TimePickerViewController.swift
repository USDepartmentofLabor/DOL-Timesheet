//
//  TimePickerViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/10/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

protocol TimePickerProtocol: class {
    func timeChanged(sourceView: UIView, datePicker: UIDatePicker)
}

class TimePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    var sourceView: UIView!
    
    weak var delegate: TimePickerProtocol?
    var pickerMode: UIDatePicker.Mode = .countDownTimer
    var countdownDuration: TimeInterval = 0
    var currentDate: Date?
    
    deinit {
        print("TimePicker deinit called")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override var preferredContentSize: CGSize {
        get {
            let height: CGFloat = 200
            return CGSize(width: super.preferredContentSize.width, height: height)
        }
        set { super.preferredContentSize = newValue }
    }
    
    func setupView() {
        datePicker.datePickerMode = pickerMode
        if pickerMode == .countDownTimer {
            let duration: Int = countdownDuration > 0 ? Int(countdownDuration) : 900 // Default to 15 min
            let calendar = Calendar(identifier: .gregorian)
            let date = DateComponents(calendar: calendar, hour: 0, minute: 0, second: duration).date!
            datePicker.setDate(date, animated: true)
        }
        else if pickerMode == .time, let date = currentDate {
            datePicker.date = date
        }
    }
    
    
    @IBAction func timeChanged(_ sender: Any) {
//        delegate?.timeChanged(sourceView: sourceView, datePicker: datePicker)
    }
}


