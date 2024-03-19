//
//  SelfSizedTableView.swift
//  DOL-Timesheet
//
//  Created by Greg Gruse on 3/19/24.
//  Copyright © 2024 Department of Labor. All rights reserved.
//

import UIKit

final class SelfSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
