//
//  ProfileModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/29/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import CoreData

class ProfileModel {
    
    private var _currentUser: User?
    var currentUser: User? {
        get {
            if _currentUser == nil || _currentUser?.managedObjectContext == nil {
                _currentUser = User.getCurrentUser(context: context)
            }
            
            return _currentUser
        }
    }
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
//        currentUser = User.getCurrentUser(context: context)
//
//        if currentUser == nil {
//            return nil
//        }
    }
    
    var profileExists: Bool {
        get {
            return (currentUser != nil && currentUser?.name != nil)
        }
    }
    
    var isEmployer: Bool {
        get {
            return currentUser is Employer ? true: false
        }
    }
    
    func newProfile(type: UserType, user: User) -> User {
        let newUser: User
        if type == .employer {
            newUser = Employer(context: context)
        }
        else {
            newUser = Employee(context: context)
        }
        print("GGG Onboarding: ProfileModel-newProfile created based on previous user: \(newUser.debugDescription)")
        newUser.currentUser = true
        newUser.name = user.name
        newUser.email = user.email
        newUser.phone = user.phone
        newUser.imageData = user.imageData
        _currentUser = user

        return newUser
    }
    
    func newProfile(type: UserType, name: String) -> User {
//        if currentUser != nil {
//            return currentUser!
//        }
        
        let user: User
        if type == .employer {
            user = Employer(context: context)
        }
        else {
            user = Employee(context: context)
        }
        print("GGG Onboarding: ProfileModel-newProfile created: \(user.debugDescription)")
        user.currentUser = true
        user.name = name
        _currentUser = user

        return user
    }
    
    func delete(employmentInfo: EmploymentInfo) {
        var employedUser: User? = nil
        
        if let employee = currentUser as? Employee {
            employedUser = employmentInfo.employer
            employee.removeFromEmployers(employmentInfo)
        }
        else if let employer = currentUser as? Employer {
            employedUser = employmentInfo.employee
            employer.removeFromEmployees(employmentInfo)
        }
        
        
//        context.delete(employmentInfo)
        if let employedUser = employedUser {
            context.delete(employedUser)
        }
    }
}
