//
//  UIImage+Extension.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func normalizedImage() -> UIImage? {
        
        if (self.imageOrientation == UIImage.Orientation.up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}


extension UIImageView {
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    
        self.addBorder(cornerRadius: self.frame.height / 2)
        self.image = anyImage
    }
}
