//
//  SettingsDetailViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 10/17/22.
//  Copyright © 2022 Department of Labor. All rights reserved.
//

import UIKit

class SettingsDetailsViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesField: UITextField!
    
    
    @IBOutlet weak var workweekStartLabel: UILabel!
    @IBOutlet weak var infoWorkweekStartButton: UIButton!
    @IBOutlet weak var workweekStartField: UITextField!
    @IBOutlet weak var workweekStartPicker: UIPickerView!
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var frequencyButton: UIButton!
    @IBOutlet weak var frequencyField: UITextField!
    @IBOutlet weak var frequencyPicker: UIPickerView!
    
    @IBOutlet weak var payRatesLabel: UILabel!
    @IBOutlet weak var payEditButton: UIButton!
    @IBOutlet weak var payInfoButton: UIButton!
    @IBOutlet weak var payField: UITextField!
    @IBOutlet weak var rateField: UITextField!
    @IBOutlet weak var payNotesField: UITextField!
    
    @IBOutlet weak var timeRoundLabel: UILabel!
    @IBOutlet weak var infoTimeRoundButton: UIButton!
    @IBOutlet weak var timeRoundedButton: UIButton!
    @IBOutlet weak var timeNotRoundedButton: UIButton!
    
    @IBOutlet weak var overtimeLabel: UILabel!
    @IBOutlet weak var infoOvertimeButton: UIButton!
    @IBOutlet weak var eligibleButton: UIButton!
    @IBOutlet weak var exemptButton: UIButton!
    
    
}
