//
//  ProfileTableViewCell.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 6/14/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

class SoftenProfileTableViewCell: UITableViewCell {
    class var nibName: String { return "SoftenProfileTableViewCell" }
    class var reuseIdentifier: String { return "SoftenProfileTableViewCell" }

    @IBOutlet weak var employmentLabel: UILabel!
    @IBOutlet weak var profileCellView: UIView!

    var firstItem: Bool = false
    var lastItem: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if firstItem {
            profileCellView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        } else if lastItem {
            profileCellView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        } else if firstItem && lastItem {
            profileCellView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        }
    }
    
    public func addborder() {
//        topBackgroundView.layer.cornerRadius = firstItem ? 10.0 : 0.0
//        topBackgroundView.clipsToBounds = true
//        bottomBackgroundView.layer.cornerRadius = lastItem ? 10.0 : 0.0
//        bottomBackgroundView.clipsToBounds = true
        
        if firstItem {
            profileCellView.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        } else if lastItem {
            profileCellView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        } else if firstItem && lastItem {
            profileCellView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        }
    }
    
}
