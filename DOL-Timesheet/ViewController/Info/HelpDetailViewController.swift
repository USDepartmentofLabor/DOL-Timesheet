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
    @IBOutlet weak var details: UILabel!
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
        details.text = helpItem.body
        setupAccessibility()
    }
    
    func setupAccessibility() {
//        displayLogo.isAccessibilityElement = true
//        displayLogo.accessibilityLabel = "whd_logo".localized
    }

}
