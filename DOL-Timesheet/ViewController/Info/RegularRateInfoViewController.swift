//
//  RegularRateInfoViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 12/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class RegularRateInfoViewController: UIViewController {

    enum RegularRatePaymentType: Int {
        case excluded
        case included
    }
    
    static let fslaURL = "https://webapps.dol.gov/elaws/whd/flsa/overtime/"
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var paymentTypeSegmentView: UISegmentedControl!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var paymentTypesStackView: UIStackView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var completionHandler: (()->Void)?

    let includedList = [NSLocalizedString("regular_rate_include1", comment: "regular_rate_include1"),
    NSLocalizedString("regular_rate_include2", comment: "regular_rate_include2"),
    NSLocalizedString("regular_rate_include3", comment: "regular_rate_include3"),
    NSLocalizedString("regular_rate_include4", comment: "regular_rate_include4")]

    let excludedList = [NSLocalizedString("regular_rate_exclude1", comment: "regular_rate_exclude1"),
    NSLocalizedString("regular_rate_exclude2", comment: "regular_rate_exclude2"),
    NSLocalizedString("regular_rate_exclude3", comment: "regular_rate_exclude3"),
    NSLocalizedString("regular_rate_exclude4", comment: "regular_rate_exclude4"),
    NSLocalizedString("regular_rate_exclude5", comment: "regular_rate_exclude5"),
    NSLocalizedString("regular_rate_exclude6", comment: "regular_rate_exclude6"),
    NSLocalizedString("regular_rate_exclude7", comment: "regular_rate_exclude7"),
    NSLocalizedString("regular_rate_exclude8", comment: "regular_rate_exclude8")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        displayPaymentTypes(type: .excluded)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize =  CGSize(width: contentView.bounds.size.width,
                                       height: contentView.bounds.size.height + 37)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        preferredContentSize =  CGSize(width: contentView.bounds.size.width,
                                       height: contentView.bounds.size.height + 37)
    }

    func setupView() {
        infoLabel.scaleFont(forDataType: .aboutText)
        infoLabel.text = NSLocalizedString("info_regular_rate_pay", comment: "The regular rate of pay, upon which an employer calculates an employee’s overtime rate, cannot be less than the minimum wage. The regular rate includes all payment for employment except certain payments that the law allows employers to exclude.")
        
        infoTextView.textContainerInset = UIEdgeInsets.zero
        
        let fslaInfoStr = NSMutableAttributedString(string: NSLocalizedString("fsla_info", comment: "fsla_info"))
        let linkedText = NSLocalizedString("fsla_linked_text", comment: "fsla_linked_text")
        _ = fslaInfoStr.setAsLink(textToFind: linkedText, linkURL: FSLAInfoViewController.fslaURL)
        
        fslaInfoStr.addAttribute(.font, value: Style.scaledFont(forDataType: .aboutText), range: NSRange(location: 0, length: fslaInfoStr.length))
        infoTextView.attributedText = fslaInfoStr
        
        setupAccessibility()
    }
    
    func displayPaymentTypes(type: RegularRatePaymentType) {
        paymentTypesStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        let typeStr = (type == .included) ? includedList : excludedList
        
        typeStr.forEach {
            let typeLabel = UILabel()
            typeLabel.text = $0
            typeLabel.numberOfLines = 0
            typeLabel.scaleFont(forDataType: .aboutText)
            paymentTypesStackView.addArrangedSubview(typeLabel)
        }
    }
    
    @IBAction func closeClick(_ sender: Any) {
        dismiss(animated: false, completion: completionHandler)
    }
    
    func setupAccessibility() {
        closeBtn.accessibilityLabel = NSLocalizedString("close", comment: "Close")
    }

    @IBAction func paymentTypesClicked(_ sender: Any) {
        
        guard let type = RegularRatePaymentType(rawValue: paymentTypeSegmentView.selectedSegmentIndex)
            else { return }
        
        displayPaymentTypes(type: type)
    }
}
