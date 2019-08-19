//
//  ProfileTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/30/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    class var reuseIdentifier: String { return "ProfileTableViewCell" }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    
    @IBOutlet weak var detailsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupView() {
        nameLabel.scaleFont(forDataType: .profileCellTitle1)
        addressLabel.scaleFont(forDataType: .profileCellTitle2)
        paymentLabel.scaleFont(forDataType: .profileCellTitle2)
        
        setupAccessibility()
    }
    
    func setupAccessibility() {
        isAccessibilityElement = false
        detailsImage.isAccessibilityElement = true
        detailsImage.accessibilityLabel = NSLocalizedString("details", comment: "Details")
        detailsImage.accessibilityHint = NSLocalizedString("display_details", comment: "Tap to Display Details")
        detailsImage.accessibilityTraits = [.button]
        accessibilityElements = [nameLabel as Any, addressLabel as Any, paymentLabel as Any, detailsImage as Any]
    }
    
    func displayEmployee(employmentModel: EmploymentModel) {
        nameLabel.text = employmentModel.employeeName
        addressLabel.text = employmentModel.employeeAddress?.description
        paymentLabel.text = employmentModel.paymentTypeTitle
    }
    
    func displayEmployer(employmentModel: EmploymentModel) {
        nameLabel.text = employmentModel.employerName
        addressLabel.text = employmentModel.employerAddress?.description
        paymentLabel.text = employmentModel.paymentTypeTitle
    }
}
