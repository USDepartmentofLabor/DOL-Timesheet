//
//  ResourcesViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ResourcesViewController: UIViewController {

    private static let emailLink = "https://webapps.dol.gov/contactwhd/"
    private static let contactOfficeLink = "https://www.dol.gov/whd/local/"
    private static let whdWebsiteLink = "http://www.dol.gov/whd"
    
    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var phoneTextView1: UITextView!
    @IBOutlet weak var phoneTextView2: UITextView!
    @IBOutlet weak var phoneHoursLabel: UILabel!
    @IBOutlet weak var emailTextView: UITextView!
    @IBOutlet weak var contactTextView: UITextView!
    @IBOutlet weak var whdWebsiteTextView: UITextView!
    
    @IBOutlet weak var footerTitleLabel: UILabel!
    
    deinit {
        print("deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        displayInfo()
    }

    func setupView() {
        title = "Resources"
        contactTitleLabel.scaleFont(forDataType: .resourcesText)
        phoneTextView1.scaleFont(forDataType: .resourcesText)
        phoneTextView2.scaleFont(forDataType: .resourcesText)
        phoneHoursLabel.scaleFont(forDataType: .resourcesText)
        emailTextView.scaleFont(forDataType: .resourcesText)
        contactTextView.scaleFont(forDataType: .resourcesText)
        whdWebsiteTextView.scaleFont(forDataType: .resourcesText)
        footerTitleLabel.scaleFont(forDataType: .resourcesFooterText)
        
        phoneTextView1.textContainerInset = UIEdgeInsets.zero
        phoneTextView1.textContainer.lineFragmentPadding = 0
        phoneTextView2.textContainerInset = UIEdgeInsets.zero
        phoneTextView2.textContainer.lineFragmentPadding = 0
        emailTextView.textContainerInset = UIEdgeInsets.zero
        emailTextView.textContainer.lineFragmentPadding = 0
        contactTextView.textContainerInset = UIEdgeInsets.zero
        contactTextView.textContainer.lineFragmentPadding = 0
        whdWebsiteTextView.textContainerInset = UIEdgeInsets.zero
        whdWebsiteTextView.textContainer.lineFragmentPadding = 0
    }
    
    func displayInfo() {
        let emailText = NSAttributedString(string: "Send an email to the Wage and Hour Division", attributes: [NSAttributedString.Key.link: ResourcesViewController.emailLink, NSAttributedString.Key.font: Style.scaledFont(forDataType: .resourcesText)])
        emailTextView.attributedText = emailText
        
        let contactText = NSAttributedString(string: "Contact the office nearest you", attributes: [NSAttributedString.Key.link: ResourcesViewController.contactOfficeLink,
            NSAttributedString.Key.font: Style.scaledFont(forDataType: .resourcesText)])
        contactTextView.attributedText = contactText

        let websiteText = NSAttributedString(string: "Wage & Hour website", attributes: [NSAttributedString.Key.link: ResourcesViewController.whdWebsiteLink,
            NSAttributedString.Key.font: Style.scaledFont(forDataType: .resourcesText)])
        whdWebsiteTextView.attributedText = websiteText
    }
}
