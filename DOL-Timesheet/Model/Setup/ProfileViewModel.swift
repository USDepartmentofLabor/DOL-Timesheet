//
//  ProfileViewModel.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 5/22/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import CoreData

class ProfileViewModel {
    var profileModel: ProfileModel
    var currentEmploymentModel: EmploymentModel?
    let managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        profileModel = ProfileModel(context: context)
    }
    
    var setupTitle: String {
        get {
            if profileModel.currentUser is Employee {
                return "add_employer".localized
            }
            
            return "add_employee".localized
        }
    }
    
    var isProfileEmployer: Bool {
        get {
            return profileModel.currentUser is Employer ? true : false
        }
    }
    
    var manageUsersTitle: String {
        get {
            if profileModel.isEmployer {
                return "manage_employees".localized
            }
            
            return "manage_employers".localized
        }
    }
    
    var addNewUserTitle: String {
        get {
            if isProfileEmployer {
                return "add_new_employee".localized
            }
            
            return "add_new_employer".localized
        }
    }
    
    var employmentUsers: [User] {
        get {
            if isProfileEmployer {
                return employmentModels.compactMap{ $0.employee }
            }
            
            return employmentModels.compactMap{ $0.employer }
        }
    }
    
    var currentEmploymentUser: User? {
        get {
            return user(for: currentEmploymentModel)
        }
    }
    
    func user(for employmentModel: EmploymentModel?) -> User? {
        guard let employmentModel = employmentModel else { return nil }
        
        if isProfileEmployer {
            return employmentModel.employee
        }
        
        return employmentModel.employer
    }
    
    func employmentModel(forUser user: User) -> EmploymentModel? {
        if isProfileEmployer {
            return employmentModels.filter{$0.employee == user}.first
        }
        else {
            return employmentModels.filter{$0.employer == user}.first
        }
    }

    func newTempEmploymentModel() -> EmploymentModel? {
        guard let user = profileModel.currentUser else { return nil }
        
        let childContext = managedObjectContext.childManagedObjectContext()
        guard let userInContext = childContext.object(with: user.objectID) as? User
            else {
                return nil
        }
        
        let employmentInfo = EmploymentInfo(context: childContext)
        print("GGG Onboarding: ProfileViewModel-newTempEmploymentModel created new EmploymentInfo: \(employmentInfo.debugDescription)")
        
        if let employee = userInContext as? Employee {
            employmentInfo.employee = employee
//            employmentInfo.employer = Employer(context: childContext)
        }
        else if let employer = userInContext as? Employer {
            employmentInfo.employer = employer
//            employmentInfo.employee = Employee(context: childContext)
        }
        print("GGG Onboarding: ProfileViewModel-newTempEmploymentModel setting employmentInfo childContext.object(with: user.objectID): \(userInContext.debugDescription)")
        
        return EmploymentModel(employmentInfo: employmentInfo)
    }

    func tempEmploymentModel(for employmentModel: EmploymentModel) -> EmploymentModel? {
        let childContext = managedObjectContext.childManagedObjectContext()
        guard let employmentInfoInContext = childContext.object(with: employmentModel.employmentInfo.objectID) as? EmploymentInfo else {
            return nil
        }
        
        return EmploymentModel(employmentInfo: employmentInfoInContext)
    }

    func deleteEmploymentModel(employmentModel: EmploymentModel) {
        profileModel.delete(employmentInfo: employmentModel.employmentInfo)
    }
    
    func changeToEmployee(employer: Employer) {
        employer.employees?.forEach {
            let empInfo: EmploymentInfo = $0 as! EmploymentInfo
            print("GGG Onboarding: ProfileViewModel-changeToEmployee deleting subs: \(empInfo.debugDescription)")
            profileModel.delete(employmentInfo: $0 as! EmploymentInfo)
        }
        if let currUser = profileModel.currentUser {
            print("GGG Onboarding: ProfileViewModel-changeToEmployee deleting primary: \(currUser.debugDescription)")
            managedObjectContext.delete(currUser)
        }
   //     managedObjectContext.rollback()
        print("GGG Onboarding: ProfileViewModel-changeToEmployee creating new profile for ??? : \(employer.debugDescription)")
        _ = profileModel.newProfile(type: .employee, name: "")
      //  managedObjectContext.delete(employer)
    }

    func changeToEmployer(employee: Employee) {
        employee.employers?.forEach {
            let empInfo: EmploymentInfo = $0 as! EmploymentInfo
            print("GGG Onboarding: ProfileViewModel-changeToEmployer deleting subs: \(empInfo.debugDescription)")
            profileModel.delete(employmentInfo: $0 as! EmploymentInfo)
        }
        if let currUser = profileModel.currentUser {
            print("GGG Onboarding: ProfileViewModel-changeToEmployer deleting primary: \(currUser.debugDescription)")
            managedObjectContext.delete(currUser)
        }
      //  managedObjectContext.rollback()
        print("GGG Onboarding: ProfileViewModel-changeToEmployer creating new profile for ??? : \(employee.debugDescription)")
        _ = profileModel.newProfile(type: .employer, name: "")
       // managedObjectContext.delete(employee)
    }

    private var employmentInfos: [EmploymentInfo]? {
        get {
            if let employer = profileModel.currentUser as? Employer {
                return employer.sortedEmployments()
            }
            else if let employee = profileModel.currentUser as? Employee {
                return employee.sortedEmployments()
            }
            
            return nil
        }
    }
    var numberOfEmploymentInfo: Int {
        get {
            return employmentInfos?.count ?? 0
        }
    }
    
    var employmentModels: [EmploymentModel] {
        var empModels = [EmploymentModel]()

        employmentInfos?.forEach {
            let employmentModel = EmploymentModel(employmentInfo: $0)
            empModels.append(employmentModel)
        }
        
        return empModels
    }
    
    func saveProfile() {
        CoreDataManager.shared().saveContext(context: managedObjectContext)
    }
}
