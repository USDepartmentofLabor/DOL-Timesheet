//
//  AppDelegate.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        setupDB()
        setupApprearance()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.shared().saveContext()
//        self.saveContext()
    }

    func setupApprearance() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "appPrimaryColor")
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                            NSAttributedString.Key.font: Style.scaledFont(forDataType: .appTitle)]
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font : Style.scaledFont(forDataType: .barButtonTitle),
            NSAttributedString.Key.foregroundColor: UIColor.white],
                                                            for: .normal)
    }
        
/*
    func setupDB() {
        var notFirstTime = UserDefaults.standard.bool(forKey: "firstTime")
        if notFirstTime {
            return
        }

        notFirstTime = true
        UserDefaults.standard.set(notFirstTime, forKey: "firstTime")

        let context = CoreDataManager.shared().viewManagedContext

        let model = UserProfileModel()
        let employee = model.createEmployee(name: "Nidhi Chawla", street1: "qe23 dsfsf", city: "Sterling", state: "VA", zipCode: "21222", currentUser: true)
        
        let employer1 = model.createEmployer(name: "ECS Federal", street1: "122 CSt", city: "Washington", state: "DC", zipCode: "20002")
        
        let employmentInfo1 = EmploymentInfo(context: context)
        employmentInfo1.minimumWage = 9.00
        employmentInfo1.covered = true
        employmentInfo1.payFrequency = .weekly
        employmentInfo1.paymentType = .hourly
        let hourlyRate1 = HourlyRate(context: context)
        hourlyRate1.name = "Rate1"
        hourlyRate1.value = 50
        employmentInfo1.addToHourlyRate(hourlyRate1)
        
        let hourlyRate2 = HourlyRate(context: context)
        hourlyRate2.name = "Night Rate"
        hourlyRate2.value = 90
        employmentInfo1.addToHourlyRate(hourlyRate2)

        employmentInfo1.employer = employer1
        employee.addToEmployers(employmentInfo1)
        
        let employer2 = model.createEmployer(name: "Library of Cong", street1: "999 sdf", city: "Washington", state: "DC", zipCode: "22002")
        let employmentInfo2 = EmploymentInfo(context: context)
        employmentInfo2.minimumWage = 16.00
        employmentInfo2.covered = true
        employmentInfo2.payFrequency = .weekly
        employmentInfo2.paymentType = .salary
        employmentInfo2.employer = employer2
        employee.addToEmployers(employmentInfo2)
        CoreDataManager.shared().saveContext(context: context)
    }
*/
}

