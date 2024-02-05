//
//  WHDTabBarController.swift
//  DOL-Timesheet
//
//  Created by George Gruse on 1/27/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import Foundation
import UIKit

class WHDTabBarController: UITabBarController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewControllers = self.viewControllers {

            // Set titles for each tab bar item
            viewControllers[0].tabBarItem.title = "contact_us".localized
            viewControllers[1].tabBarItem.title = "timesheet".localized
            viewControllers[2].tabBarItem.title = "timecard".localized
            viewControllers[3].tabBarItem.title = "my_profile".localized
            viewControllers[4].tabBarItem.title = "info_title".localized
        }
    }
}
