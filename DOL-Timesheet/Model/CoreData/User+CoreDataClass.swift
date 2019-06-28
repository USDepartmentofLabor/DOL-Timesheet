//
//  User+CoreDataClass.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/15/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(User)
public class User: NSManagedObject {
    public override func awakeFromInsert() {
        createdAt = Date()
    }

    var image: UIImage? {
        get {
            if let imageData = imageData {
                return UIImage(data: imageData)
            }
            return nil
        }
        
        set {
            imageData = newValue?.pngData()
        }
    }
    

    public class func getCurrentUser(context: NSManagedObjectContext?) -> User? {
        guard let context = context else { return nil }
        var fetchResults: [User]?
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "currentUser == %@", NSNumber(value: true))
        
        do {
            fetchResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchResults?.first
    }
    
    var address: Address? {
        get {
            return addresses?.allObjects.first as? Address
        }
    }
    
    func setAddress(street1: String?, street2: String?, city: String?, state: String?, zipCode: String?) {
        guard let context = managedObjectContext else {
            return
        }
        
        var userAddress = address
        if userAddress == nil {
            userAddress = Address(context: context)
            addToAddresses(userAddress!)
        }
        
        userAddress?.street1 = street1
        userAddress?.street2 = street2
        userAddress?.city = city
        userAddress?.state = state
        userAddress?.zipCode = zipCode
    }
}


extension User: Comparable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
    
    public static func < (lhs: User, rhs: User) -> Bool {
        guard let lhsName = lhs.name else { return true }
        guard let rhsName = rhs.name else { return false }
        
        return lhsName < rhsName
    }
}


extension User: OptionsProtocol {
    var title: String {
        return name ?? ""
    }
}
