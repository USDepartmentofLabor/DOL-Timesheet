//
//  HourlyPaymentViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/18/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HourlyPaymentViewController: UIViewController {

    var viewModel: EmploymentModel!
    
    @IBOutlet weak var titleLabelInfo: LabelInfoView!
    
    @IBOutlet weak var hourlyContentView: UIView!
    @IBOutlet weak var hourlyTitleLabel: UILabel!
    @IBOutlet weak var hourlyRateTableView: UITableView!
    @IBOutlet weak var hourlyRateTableViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        title = NSLocalizedString("hourly_payment_title", comment: "Hourly Payment Title")
        
        hourlyContentView.addBorder()
        hourlyRateTableView.estimatedRowHeight = 44
        hourlyRateTableView.rowHeight = UITableView.automaticDimension

        hourlyTitleLabel.scaleFont(forDataType: .headingTitle)
        
        if viewModel.isProfileEmployer {
            titleLabelInfo.title = NSLocalizedString("hourly_rate_employer", comment: "Hourly Rate")
            titleLabelInfo.infoType = .employer_hourlyPayRate
        }
        else {
            titleLabelInfo.title = NSLocalizedString("hourly_rate_employee", comment: "Hourly Rate")
            titleLabelInfo.infoType = .employee_hourlyPayRate
        }
        titleLabelInfo.delegate = self
        
        if viewModel?.hourlyRates?.count ?? 0 > 0 {
            loadHourlyRate()
        }
        else {
            addRate()
        }
    }

    @IBAction func addMoreRateClick(_ sender: Any) {
        addRate()
    }
    
    func addRate() {
        viewModel?.newHourlyRate()
        loadHourlyRate()
    }

    func loadHourlyRate() {
        hourlyRateTableView.reloadData()
        UIView.animate(withDuration: 0, animations: {
            self.hourlyRateTableView.layoutIfNeeded()
        }) { (complete) in
            self.hourlyRateTableViewHeightConstraint.constant = self.hourlyRateTableView.contentSize.height
        }
    }
}

extension HourlyPaymentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hourlyRates?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HourlyRateTableViewCell.reuseIdentifier) as! HourlyRateTableViewCell
        
        if let hourlyRate = viewModel.hourlyRates?[indexPath.row] {
            cell.hourlyRate = hourlyRate
        }

        cell.itemIndex = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension HourlyPaymentViewController: HourlyRateCellDelegate {
    func removeItem(index: Int) {
        guard index < viewModel?.hourlyRates?.count ?? 0 else { return }
        
        if let hourlyRate = viewModel.hourlyRates?[index] {
            viewModel.deleteHourlyRate(hourlyRate: hourlyRate)
        }
        loadHourlyRate()
    }
}

extension HourlyPaymentViewController {
    func validateInput() -> String? {
        var errorStr: String? = nil
        
        if (viewModel?.hourlyRates?.count ?? 0) < 1 {
            errorStr = NSLocalizedString("err_add_hourly_rate", comment: "Add Hourly Rate")
        }
        else {
            viewModel?.hourlyRates?.forEach {
                if ($0.name ?? "").isEmpty {
                    errorStr = NSLocalizedString("err_add_hourly_rate_name", comment: "Add Hourly Rate name")
                    return
                }
                else if $0.value <= 0 {
                    errorStr = NSLocalizedString("err_add_hourly_rate_value", comment: "Add Hourly Rate value")
                    return
                }
            }
        }
        
        return errorStr
    }
}

extension HourlyPaymentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        return true
    }
}
