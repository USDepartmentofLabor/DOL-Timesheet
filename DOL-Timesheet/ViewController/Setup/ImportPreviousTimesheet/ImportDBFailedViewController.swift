//
//  ImportDBFailedViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ImportDBFailedViewController: UIViewController {

    
    weak var importDelegate: ImportDBProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func yesClick(_ sender: Any) {
        importDelegate?.emailOldDB()
    }
    
    @IBAction func noClick(_ sender: Any) {
        importDelegate?.importDBFinish()
    }
}
