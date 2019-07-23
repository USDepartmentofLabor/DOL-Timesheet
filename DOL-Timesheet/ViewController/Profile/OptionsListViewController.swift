//
//  OptionsListViewController.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/7/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

struct State: OptionsProtocol {
    let code: String
    let title: String
    
    static let states: [State] = [State(code: "AL", title: "Alabama"),
                                  State(code: "AK", title: "Alaska"),
                                  State(code: "AZ", title: "Arizona"),
                                  State(code: "AR", title: "Arkansas"),
                                  State(code: "CA", title: "California"),
                                  State(code: "CO", title: "Colorado"),
                                  State(code: "CT", title: "Connecticut"),
                                  State(code: "DE", title: "Delaware"),
                                  State(code: "DC", title: "District Of Columbia"),
                                  State(code: "FL", title: "Florida"),
                                  State(code: "GA", title: "Georgia"),
                                  State(code: "HI", title: "Hawaii"),
                                  State(code: "ID", title: "Idaho"),
                                  State(code: "IL", title: "Illinois"),
                                  State(code: "IN", title: "Indiana"),
                                  State(code: "IA", title: "Iowa"),
                                  State(code: "KS", title: "Kansas"),
                                  State(code: "KY", title: "Kentucky"),
                                  State(code: "LA", title: "Louisiana"),
                                  State(code: "ME", title: "Maine"),
                                  State(code: "MD", title: "Maryland"),
                                  State(code: "MA", title: "Massachusetts"),
                                  State(code: "MI", title: "Michigan"),
                                  State(code: "MN", title: "Minnesota"),
                                  State(code: "MS", title: "Mississippi"),
                                  State(code: "MO", title: "Missouri"),
                                  State(code: "MT", title: "Montana"),
                                  State(code: "NE", title: "Nebraska"),
                                  State(code: "NV", title: "Nevada"),
                                  State(code: "NH", title: "New Hampshire"),
                                  State(code: "NJ", title: "New Jersey"),
                                  State(code: "NM", title: "New Mexico"),
                                  State(code: "NY", title: "New York"),
                                  State(code: "NC", title: "North Carolina"),
                                  State(code: "ND", title: "North Dakota"),
                                  State(code: "OH", title: "Ohio"),
                                  State(code: "OK", title: "Oklahoma"),
                                  State(code: "OR", title: "Oregon"),
                                  State(code: "PA", title: "Pennsylvania"),
                                  State(code: "RI", title: "Rhode Island"),
                                  State(code: "SC", title: "South Carolina"),
                                  State(code: "SD", title: "South Dakota"),
                                  State(code: "TN", title: "Tennessee"),
                                  State(code: "TX", title: "Texas"),
                                  State(code: "UT", title: "Utah"),
                                  State(code: "VT", title: "Vermont"),
                                  State(code: "VA", title: "Virginia"),
                                  State(code: "WA", title: "Washington"),
                                  State(code: "WV", title: "West Virginia"),
                                  State(code: "WI", title: "Wisconsin"),
                                  State(code: "WY", title: "Wyoming"),
                                  State(code: "PR", title: "Puerto Rico")]
}

class OptionsListViewController<T : OptionsProtocol>: UITableViewController {
    var options: [T] = [T]()
    
    var addNewRowTitle: String? // Set this Title if you need last row to show Add Title
    
    var didSelect: (UIViewController, T?) -> () = { _,_  in }
    
    init(options: [T], title: String, addRowTitle: String? = nil) {
        self.options = options
        super.init(style: .plain)
        self.title = title
        self.addNewRowTitle = addRowTitle
        self.tableView.tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let height = tableView.contentSize.height
        let size =  CGSize(width: super.preferredContentSize.width, height: height)
        preferredContentSize = size
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = options.count
        
        if addNewRowTitle != nil {
            numRows += 1
        }
        return numRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cellId"
        let cell: UITableViewCell
        
        if let c = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = c
        }
        else {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.row < options.count {
            cell.textLabel?.text = options[indexPath.row].title
        }
        else {
            cell.textLabel?.text = addNewRowTitle
        }
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.scaleFont(forDataType: .nameValueText)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: T?
        
        if indexPath.row < options.count {
            item = options[indexPath.row]
        }
        else {
            item = nil
        }
        didSelect(self, item)
    }
}
