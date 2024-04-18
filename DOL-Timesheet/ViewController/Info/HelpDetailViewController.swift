//
//  HelpDetailViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class HelpDetailViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var details: UITextView!
    var helpItem: HelpItem = HelpItem(title: "", body: "")
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarSettings()
        setupView()
    }
    
    func setupView() {
        let backButton = UIBarButtonItem()
        backButton.title = "back".localized
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
                
        navBar.title = helpItem.title
        
        let htmlText = helpItem.body
        if let data = htmlText.data(using: .utf8) {
            if let attributedText = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                details.attributedText = attributedText
            }
        }
        
        details.textColor = UIColor(named: "valueActiveText")
        details.font = UIFont.systemFont(ofSize: 17)
        setupAccessibility()
    }
    
    func setupAccessibility() {
//        displayLogo.isAccessibilityElement = true
//        displayLogo.accessibilityLabel = "whd_logo".localized
    }

}
