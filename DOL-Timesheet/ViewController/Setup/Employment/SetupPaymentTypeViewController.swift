//
//  SetupPaymentTypeViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/16/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SetupPaymentTypeViewController: SetupBaseEmploymentViewController {

    @IBOutlet weak var titleLabelInfo: LabelInfoView!
    var paymentTypes: [PaymentType] = [.hourly, .salary]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupView() {
        super.setupView()
        
        title = "payment_type".localized
        
        if viewModel?.isProfileEmployer ?? false {
            titleLabelInfo.title = "payment_type_employer".localized
            titleLabelInfo.infoType = .employer_paymentType
        }
        else {
            titleLabelInfo.title = "payment_type_employee".localized
            titleLabelInfo.infoType = .employee_paymentType
        }
        titleLabelInfo.delegate = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destVC = segue.destination as? EditEmploymentInfoViewController {
            destVC.viewModel = viewModel
            destVC.delegate = delegate
        }
    }
}


extension SetupPaymentTypeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentTypeTableViewCell.reuseIdentifier) as! PaymentTypeTableViewCell
        
        if indexPath.row < paymentTypes.count {
            let paymentType = paymentTypes[indexPath.row]
            cell.paymentType = paymentType
            cell.delegate = self
        }
        
        return cell
    }
}

// MARK: PaymentTypeCell Delegate
extension SetupPaymentTypeViewController: PaymentTypeCellDelegate {
    func didSelect(paymentType: PaymentType) {
        
        viewModel?.paymentType = paymentType
        if paymentType == .hourly {
            performSegue(withIdentifier: "hourlyPaymentInfo", sender: self)
        }
        else if paymentType == .salary {
            performSegue(withIdentifier: "salaryPaymentInfo", sender: self)
        }
    }
}
