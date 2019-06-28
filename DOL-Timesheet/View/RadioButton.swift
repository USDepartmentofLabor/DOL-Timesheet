//
//  RadioButton.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 6/5/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class RadioButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            
        configure()
    }
        
    func configure() {
        let unselectedImage = #imageLiteral(resourceName: "radioUnnSelect")
        let selectedImage = #imageLiteral(resourceName: "radioSelect")
        setImage(selectedImage, for: .selected)
        setImage(unselectedImage, for: .normal)
        setTitleColor(.darkText, for: .normal)
        tintColor = .clear
        
        titleLabel?.scaleFont(forDataType: .radioButton)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = self.titleLabel!.intrinsicContentSize
        return CGSize(width: size.width + contentEdgeInsets.left + contentEdgeInsets.right, height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = imageView {
            let imageBounds =  imageView.bounds
            titleEdgeInsets = UIEdgeInsets(top: 0, left: imageBounds.width + 2 , bottom: 0, right: 0)
        }
        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width

    }
}
