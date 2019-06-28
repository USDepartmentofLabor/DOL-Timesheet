//
//  Bundle+Extension.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/23/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation


extension Bundle {
    var appName: String {
        return infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildNumber: String {
        return infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    }
}
