//
//  SetupPaymentFrequencyViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SetupPaymentFrequencyViewController: SetupBaseEmploymentViewController {
  
    
    @IBOutlet weak var titleLabelInfo: LabelInfoView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    override func setupView() {
        super.setupView()
        
        title = "payment_frequency".localized
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        if viewModel?.isProfileEmployer ?? false {
            titleLabelInfo.title = "payment_frequency_employer".localized
            titleLabelInfo.infoType = .employer_paymentFrequency
        }
        else {
            titleLabelInfo.title = "payment_frequency_employee".localized
            titleLabelInfo.infoType = .employee_paymentFrequency
        }
        titleLabelInfo.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
}


extension SetupPaymentFrequencyViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PaymentFrequency.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentFrequencyTableViewCell.reuseIdentifier) as! PaymentFrequencyTableViewCell
        
        cell.paymentFrequency = PaymentFrequency.allCases[indexPath.row]
        cell.delegate = self

        return cell
    }
}

extension SetupPaymentFrequencyViewController: PaymentFrequencyCellDelegate {
    func select(paymentFrequency: PaymentFrequency?) {

        viewModel?.paymentFrequency = paymentFrequency ?? .weekly
        performSegue(withIdentifier: "showWorkWeek", sender: self)
    }
}

