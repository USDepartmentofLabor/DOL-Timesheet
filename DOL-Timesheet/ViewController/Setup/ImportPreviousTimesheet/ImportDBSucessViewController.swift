//
//  ImportDBSucessViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/8/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class ImportDBSucessViewController: UIViewController {

    weak var importDelegate: ImportDBProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func okClick(_ sender: Any) {
        importDelegate?.importDBFinish()
    }
}
