//
//  Address+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/1/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Address)
public class Address: NSManagedObject {

}

extension Address {
    public override func awakeFromInsert() {
        createdAt = Date()
    }

    override public var description: String {
        var addressText = "\(street1 ?? "")"
        if let street2 = street2, !street2.isEmpty {
            if !addressText.isEmpty {
                addressText += "\n"
            }

            addressText += "\(street2)"
        }
        
        if let city = city, !city.isEmpty {
            if !addressText.isEmpty {
                addressText += "\n"
            }

            addressText += "\(city)"
        }
        
        if !(city?.isEmpty ?? true) {
            addressText += ", "
        }
        addressText += "\(state ?? "") \(zipCode ?? "")"
        
        return addressText
    }
    
    var csv: String {
        var addressText = "\(street1 ?? "")"
        if let street2 = street2, !street2.isEmpty {
            addressText += " \(street2)"
        }
        addressText += " \(city ?? "") \(state ?? "") \(zipCode ?? "")"
        
        return addressText
    }

}
