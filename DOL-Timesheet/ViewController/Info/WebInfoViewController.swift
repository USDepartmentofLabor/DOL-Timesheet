//
//  WebInfoViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/17/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import WebKit

enum WebInfo {
    case minimumWage
    
    var url: URL? {
        let url:URL?
        switch self {
        case .minimumWage:
            url = URL(string: "https://www.dol.gov/agencies/whd/mw-consolidated")
        }
        
        return url
    }
    
    var title: String {
        let title:String
        switch self {
        case .minimumWage:
            title = "Minimum Wage Table"
        }
        
        return title
    }
}
class WebInfoViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var webInfo: WebInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        title = webInfo?.title
        
        if let url = webInfo?.url {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
}
