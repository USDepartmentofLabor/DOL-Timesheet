//
//  InfoViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

enum InfoSection: Int {
    case glossary = 0
    case resources
    case about
}


class InfoViewController: UIViewController {

    @IBOutlet weak var infoSection: UISegmentedControl!

    @IBOutlet weak var aboutContainerView: UIView!
    @IBOutlet weak var glossaryContainerView: UIView!
    @IBOutlet weak var resourcesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        title = "Info"
        displaySection(section: InfoSection.glossary)

        let font = Style.scaledFont(forDataType: .infoSection)
        infoSection.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        infoSection.setios12Style()
    }
    
    
    // Actions
    @IBAction func infoSectionChanged(_ sender: Any) {
        guard let section = InfoSection(rawValue: infoSection.selectedSegmentIndex) else { return }
        displaySection(section: section)
    }
        
    func displaySection(section: InfoSection) {
        switch section {
        case .about:
            aboutContainerView.isHidden = false
            glossaryContainerView.isHidden = true
            resourcesContainerView.isHidden = true
        case .glossary:
            aboutContainerView.isHidden = true
            glossaryContainerView.isHidden = false
            resourcesContainerView.isHidden = true
        case .resources:
            aboutContainerView.isHidden = true
            glossaryContainerView.isHidden = true
            resourcesContainerView.isHidden = false
        }
    }
}
