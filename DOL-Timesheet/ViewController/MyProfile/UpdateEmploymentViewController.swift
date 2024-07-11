//
//  UpdateEmploymentViewController.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/21/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class UpdateEmploymentViewController: UIViewController {
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var startOfPayWeekLabel: UILabel!
    @IBOutlet weak var startOfPayWeekTextField: UITextField!
    @IBOutlet weak var startOfPayWeekPicker: UIPickerView!
    @IBOutlet weak var startOfPayWeekHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstPayPeriodTitleLabel: UILabel!
    @IBOutlet weak var firstPayPeriodTextField: UITextField!
    @IBOutlet weak var firstPayPeriodDatePicker: UIDatePicker!
    @IBOutlet weak var firstPayPeriodDateHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var payFrequencyTitleLabel: UILabel!
    @IBOutlet weak var payFrequencyTextField: UITextField!
    @IBOutlet weak var payFrequencyPicker: UIPickerView!
    @IBOutlet weak var payFrequencyHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var overtimeLabel: UILabel!
    @IBOutlet weak var overtimeSwitch: UISwitch!
    
    @IBOutlet weak var stateTitleLabel: UILabel!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var stateHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stateMinimumWageLabel: UILabel!
    @IBOutlet weak var stateMinimumWageTextField: UITextField!
    @IBOutlet weak var stateView: UIView!
    
    @IBOutlet weak var rateTable: SelfSizedTableView!
    
    
    @IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var helpView: UIView!
    
    @IBOutlet weak var discardButton: UIButton!
    
    let profileViewModel: ProfileViewModel = ProfileViewModel(context: CoreDataManager.shared().viewManagedContext)
    var employmentModel: EmploymentModel?
    
    var firstPayPeriod: Date?
    var dateFormatter = {
        let formatter = DateFormatter()

        var locale = "en_EN"
        if (Localizer.currentLanguage == Localizer.SPANISH) {
            locale = "es_ES"
        }
        
        formatter.locale = Locale(identifier: locale)
        return formatter
    }()

    var selectedWeekday: Weekday?
    var selectedPayFrequency: PaymentFrequency? = .daily
    var selectedState: State?
    
    var stateMinWages: StateMinWage = StateMinWage.init()
    
    var minimumWage: NSNumber = 0.0 {
        didSet {
            if isViewLoaded {
                stateMinimumWageTextField.text = NumberFormatter.localisedCurrencyStr(from: minimumWage)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        self.navigationController?.navigationBar.tintColor = .linkColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        if employmentModel != nil {
            setupData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameView.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
        stateView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
        
        updateCellCorners()

        helpView.layer.cornerRadius = 10.0
    }
    
    func setupView() {
        title = "new_employer".localized
        if profileViewModel.isProfileEmployer {
            title = "new_employee".localized
        }
        
        nameLabel.text = "name_or_nickname".localized
        nameTextField.text = ""
        
        startOfPayWeekLabel.text = "start_of_pay_week".localized
        startOfPayWeekTextField.text = ""
        startOfPayWeekHeightConstraint.constant = 0
        
        firstPayPeriodTitleLabel.text = "start_date_of_first_pay_period".localized
        firstPayPeriodTextField.text = ""
        firstPayPeriodDateHeightConstraint.constant = 0
        firstPayPeriodDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        let locale = Localizer.currentLanguage == Localizer.SPANISH ? Locale(identifier: "es_ES") : Locale(identifier: "en_EN")

        
        firstPayPeriodDatePicker.locale = locale
        firstPayPeriodDatePicker.calendar = locale.calendar
        firstPayPeriodDatePicker.calendar.firstWeekday = 1

        payFrequencyTitleLabel.text = "pay_frequency".localized
        payFrequencyTextField.text = ""
        payFrequencyHeightConstraint.constant = 0
        
        overtimeLabel.text = "eligible_for_overtime_non_Exempt".localized
        overtimeSwitch.isOn = true
        
        stateTitleLabel.text = "state_you_work_in".localized
        stateTextField.text = ""
        stateHeightConstraint.constant = 0
        
        stateMinimumWageLabel.text = "state_minimum_wage".localized
        stateMinimumWageTextField.text = ""
        
        helpLabel.text = "help".localized
        
        discardButton.layer.borderWidth = 1.0
        discardButton.layer.cornerRadius = 5.0
        discardButton.layer.borderColor = UIColor.red.cgColor

        discardButton.setTitleColor(UIColor.red, for: .normal)
        discardButton.setTitleColor(UIColor.white, for: .highlighted)
        discardButton.setTitle("discard".localized, for: .normal)
        
        discardButton.isHidden = true
        
    }
    
    func setupData() {
        guard let safeEmploymentModel = employmentModel else {return}
        
        title = safeEmploymentModel.employmentUser?.name
        nameTextField.text = safeEmploymentModel.employmentUser?.name
        
//        startOfPayWeekPicker.value(forKey: safeEmploymentModel.employmentInfo.workWeekStartDay.title)
        startOfPayWeekTextField.text = safeEmploymentModel.employmentInfo.workWeekStartDay.title
                
        
        if let selectedStartOfPayWeek = Weekday.allCases.firstIndex(where: { $0.title == safeEmploymentModel.employmentInfo.workWeekStartDay.title }) {
            // Set the selected row in the picker view
            startOfPayWeekPicker.selectRow(selectedStartOfPayWeek, inComponent: 0, animated: true)
        }
        
        let startDate = safeEmploymentModel.employmentInfo.startDate ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MM/dd/yy"
        
        firstPayPeriodTextField.text = dateFormatter.string(from: startDate)
        firstPayPeriodDatePicker.setDate(startDate, animated: true)
        
//        payFrequencyPicker.value(forKey: safeEmploymentModel.employmentInfo.payFrequency.title)
        payFrequencyTextField.text = safeEmploymentModel.employmentInfo.payFrequency.title
        
        if let selectedPayFrequency = PaymentFrequency.allCases.firstIndex(where: { $0.title == safeEmploymentModel.employmentInfo.payFrequency.title }) {
            // Set the selected row in the picker view
            payFrequencyPicker.selectRow(selectedPayFrequency, inComponent: 0, animated: true)
        }
        
        overtimeSwitch.isOn = false
        if safeEmploymentModel.overtimeEligible {
            overtimeSwitch.isOn = true
        }
        
//        statePicker.value(forKey: safeEmploymentModel.employmentUser?.address?.state ?? "West Virginia")
        stateTextField.text = safeEmploymentModel.employmentUser?.address?.state
//        stateMinimumWageTextField.text = String(format: "%.2f", safeEmploymentModel.minimumWage)
        stateMinimumWageTextField.text = String(NumberFormatter.localisedCurrencyStr(from: safeEmploymentModel.minimumWage))
        
        
        
        if let selectedState = State.states.firstIndex(where: { $0.title == safeEmploymentModel.employmentUser?.address?.state }) {
            // Set the selected row in the picker view
            statePicker.selectRow(selectedState, inComponent: 0, animated: true)
        }
        
        discardButton.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "updateEmploymentHelpScreen",
            let helpVC = segue.destination as? HelpTableViewController {
            helpVC.helpItems = [
                HelpItem(title: "pay_frequency".localized, body: "info_employee_payment_frequency".localized),
                HelpItem(title: "start_of_pay_week".localized, body: "info_employee_workweek".localized),
                HelpItem(title: "overtime_eligibility".localized, body: "info_overtime_eligible".localized),
                HelpItem(title: "state_minimum_wage".localized, body: "info_state_minimumWage".localized),
                HelpItem(title: "flsa".localized, body: "fsla_info1".localized + " " + "fsla_info2".localized)
            ]
        }
        
        if segue.identifier == "updateRateSegue" {
            if let destinationVC = segue.destination as? UpdateRateViewController {
                destinationVC.hourlyRate = sender as? HourlyRate
                destinationVC.employmentModel = employmentModel
            }
        }
    }
    
    
    @IBAction func discardPressed(_ sender: Any) {
        var title = "delete_employee".localized
        var message = "delete_employee_warning".localized
        if !profileViewModel.isProfileEmployer {
            title = "delete_employer".localized
            message = "delete_employer_warning".localized
        }
        
        let alertController =
        UIAlertController(title: title,
                          message: message,
                          preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "delete".localized, style: .destructive) { _ in
            }
        )
        present(alertController, animated: true)
    }
}

extension UpdateEmploymentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if employmentModel?.paymentType == .salary {
            return 1
        }
        
        let numberOfRates = employmentModel?.hourlyRates?.count ?? 0
        return numberOfRates + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: SoftenProfileTableViewCell.reuseIdentifier) as! SoftenProfileTableViewCell
        
        guard let safeEmploymentModel = employmentModel else {
            cell.employmentLabel.text = "Add a Rate..."
            return cell
        }
        
        if employmentModel?.paymentType == .hourly {
            if indexPath.row == safeEmploymentModel.hourlyRates?.count {
                cell.employmentLabel.text = "Add a Rate..."
                return cell
            }
            
            let rate = safeEmploymentModel.hourlyRates?[indexPath.row]
            cell.employmentLabel.text = rate?.name
            
            return cell
        }
        
        cell.employmentLabel.text = safeEmploymentModel.paymentType.title
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = "rates".localized
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "timesheetBackgroundColor")

        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 30, height: 12))
        headerLabel.text = title
        headerLabel.textColor = UIColor(named: "labelTextInactive")
        headerLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15 // Change this to your desired height
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteEmployment(indexPath: indexPath)
        }
    }
    
    func deleteEmployment(indexPath: IndexPath) {
        let employmentModel = profileViewModel.employmentModels[indexPath.row]
        
        let titleMsg: String
        let errorMsg: String
        if employmentModel.isProfileEmployer {
            titleMsg = "delete_employee".localized
            errorMsg = "delete_confirm_employee_info".localized
        }
        else {
            titleMsg = "delete_employer".localized
            errorMsg = "delete_confirm_employer_info".localized
        }
        
        let alertController = UIAlertController(title: titleMsg,
                                                message: errorMsg,
                                                preferredStyle: .alert)
        
        alertController.addAction(
            UIAlertAction(title: "cancel".localized, style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "delete".localized, style: .destructive) { _ in
                self.profileViewModel.deleteEmploymentModel(employmentModel: employmentModel)
                self.rateTable.beginUpdates()
                self.rateTable.deleteRows(at: [indexPath], with: .automatic)
                self.rateTable.endUpdates()
            
        })
        
        present(alertController, animated: true)
    }
    
    private func updateCellCorners() {
        let numberOfRows = rateTable.numberOfRows(inSection: 0)
        
        for (index, cell) in rateTable.visibleCells.enumerated() {
            guard let roundedCell = cell as? SoftenProfileTableViewCell else { continue }
            
            roundedCell.layer.mask = nil
            
            if numberOfRows - 1 == 0 {
                roundedCell.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
            } else if index == numberOfRows - 1 {
                roundedCell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
            } else if index == 0{
                roundedCell.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            }
        }
    }
}

extension UpdateEmploymentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let safeEmploymentModel = employmentModel else {
            tableView.deselectRow(at: indexPath, animated: false)
            performSegue(withIdentifier: "updateRateSegue", sender: nil)
            return
        }

        if indexPath.row == safeEmploymentModel.hourlyRates?.count {
            tableView.deselectRow(at: indexPath, animated: false)
            performSegue(withIdentifier: "updateRateSegue", sender: nil)
            return
        }

        let selectedRate = safeEmploymentModel.hourlyRates?[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "updateRateSegue", sender: selectedRate)
    }
}

extension UpdateEmploymentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == otherNameField {
//            
//        }
//        else {
//            
//        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == startOfPayWeekTextField {
            if startOfPayWeekHeightConstraint.constant > 1 {
                startOfPayWeekHeightConstraint.constant = 0
            } else {
                if startOfPayWeekTextField.text?.count == 0 {
                    startOfPayWeekTextField.text? = Weekday.sunday.title
                }
                startOfPayWeekHeightConstraint.constant = 216
                setFirstDatePickerHeight(height: 0, relatedBy: .equal)
                payFrequencyHeightConstraint.constant = 0
                stateHeightConstraint.constant = 0
            }
            return false
        } else if textField == firstPayPeriodTextField {
            if firstPayPeriodDateHeightConstraint.constant > 1 {
                setFirstDatePickerHeight(height: 0, relatedBy: .equal)
            } else {
                if firstPayPeriodTextField.text?.count == 0 {
                    firstPayPeriod = Date()
                    dateFormatter.dateFormat = "MMMM d, YYYY"
                    dateFormatter.locale = Locale(identifier: Localizer.currentLanguage)
                    let formattedDate = dateFormatter.string(from: firstPayPeriod!)
                    let formattedDateCapitalized = formattedDate.prefix(1).capitalized + formattedDate.dropFirst()
                    
                    firstPayPeriodTextField.text = formattedDateCapitalized
                }
                
                startOfPayWeekHeightConstraint.constant = 0
                setFirstDatePickerHeight(height: 307, relatedBy: .greaterThanOrEqual)
                payFrequencyHeightConstraint.constant = 0
                stateHeightConstraint.constant = 0
            }
            return false
        } else if textField == payFrequencyTextField {
            if payFrequencyHeightConstraint.constant > 1 {
                payFrequencyHeightConstraint.constant = 0
            } else {
                if payFrequencyTextField.text?.count == 0 {
                    payFrequencyTextField.text? = PaymentFrequency.daily.title
                }
                
                startOfPayWeekHeightConstraint.constant = 0
                setFirstDatePickerHeight(height: 0, relatedBy: .equal)
                payFrequencyHeightConstraint.constant = 216
                stateHeightConstraint.constant = 0
            }
            return false
        } else if textField == stateTextField {
            if stateHeightConstraint.constant > 1 {
                stateHeightConstraint.constant = 0
            } else {
                if stateTextField.text?.count == 0 {
                    stateTextField.text? = State.states[0].title
                }
                if stateMinimumWageTextField.text?.count == 0 {
                    stateTextField.text = State.states[0].title
                    selectedState = State.states[0]
                    if let state = stateMinWages.data.first(where: { $0.state == State.states[0].title }),
                       let minWage = state.minimumWage {
                        minimumWage = minWage as NSNumber
                        stateMinimumWageTextField.text = String(NumberFormatter.localisedCurrencyStr(from: minWage))
                    }
                }
                
                startOfPayWeekHeightConstraint.constant = 0
                setFirstDatePickerHeight(height: 0, relatedBy: .equal)
                payFrequencyHeightConstraint.constant = 0
                stateHeightConstraint.constant = 216
                
                
                
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.scrollView.scrollToBottom()
//                }
            }
            return false
        }
        
        startOfPayWeekHeightConstraint.constant = 0
        setFirstDatePickerHeight(height: 0, relatedBy: .equal)
        payFrequencyHeightConstraint.constant = 0
        stateHeightConstraint.constant = 0
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func setFirstDatePickerHeight(height: CGFloat, relatedBy: NSLayoutConstraint.Relation) {
        firstPayPeriodDateHeightConstraint.constant = height
        

        // Create a new constraint with a greater than or equal to relation
        let newHeightConstraint = NSLayoutConstraint(item: firstPayPeriodDateHeightConstraint.firstItem,
                                                      attribute: firstPayPeriodDateHeightConstraint.firstAttribute,
                                                      relatedBy: relatedBy,
                                                      toItem: firstPayPeriodDateHeightConstraint.secondItem,
                                                      attribute: firstPayPeriodDateHeightConstraint.secondAttribute,
                                                      multiplier: firstPayPeriodDateHeightConstraint.multiplier,
                                                      constant: firstPayPeriodDateHeightConstraint.constant)

        firstPayPeriodDateHeightConstraint.isActive = false
        newHeightConstraint.isActive = true

        // Optionally, update the IBOutlet reference
        firstPayPeriodDateHeightConstraint = newHeightConstraint
        
    }
}


extension UpdateEmploymentViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == startOfPayWeekPicker {
            startOfPayWeekTextField.text = Weekday.allCases[row].title
            selectedWeekday = Weekday.allCases[row]
            
        } else if pickerView == payFrequencyPicker {
            payFrequencyTextField.text = PaymentFrequency.allCases[row].title
            selectedPayFrequency = PaymentFrequency.allCases[row]
            
        } else {
            stateTextField.text = State.states[row].title
            selectedState = State.states[row]
            if let state = stateMinWages.data.first(where: { $0.state == State.states[row].title }),
               let minWage = state.minimumWage {
                minimumWage = minWage as NSNumber
                stateMinimumWageTextField.text = String(NumberFormatter.localisedCurrencyStr(from: minWage))
            }
            
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == startOfPayWeekPicker {
            return Weekday.allCases[row].title
        } else if pickerView == payFrequencyPicker {
            return PaymentFrequency.allCases[row].title
        } else {
            return State.states[row].title
        }
    }
}

extension UpdateEmploymentViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == startOfPayWeekPicker {
            return Weekday.allCases.count
        } else if pickerView == payFrequencyPicker {
            return PaymentFrequency.allCases.count
        } else  {
            return State.states.count
        }
    }
}

extension UpdateEmploymentViewController {
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        firstPayPeriod = selectedDate
        dateFormatter.dateFormat = "MMMM d, YYYY"
        dateFormatter.locale = Locale(identifier: Localizer.currentLanguage)
        let formattedDate = dateFormatter.string(from: firstPayPeriod!)
        let formattedDateCapitalized = formattedDate.prefix(1).capitalized + formattedDate.dropFirst()
        
        firstPayPeriodTextField.text = formattedDateCapitalized
    }
}
