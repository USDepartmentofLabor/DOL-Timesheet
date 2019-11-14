//
//  UIScrollView+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 11/14/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: true)
    }
}
