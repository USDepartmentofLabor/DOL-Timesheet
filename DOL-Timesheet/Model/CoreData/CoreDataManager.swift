//
//  CoreDataManater.swift
//  DOL-Timesheet
//
//  Created by Nidhi Chawla on 4/12/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CoreDataManager {
    
    private static var sharedCoreDataManager: CoreDataManager = {
        let coreDataManager = CoreDataManager()
        return coreDataManager
    }()
    
    
    // MARK: - Accessors
    class func shared() -> CoreDataManager {
        return sharedCoreDataManager
    }

    private init() {
        os_log("Documents Directory: %@", FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask).description)
    }
    
    lazy var model: NSManagedObjectModel = {
        return persistentContainer.managedObjectModel
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DOL_Timesheet")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    lazy var viewManagedContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
//    lazy var childManagedObjectContext: NSManagedObjectContext = {
//        // Initialize Managed Object Context
//        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        
//        // Configure Managed Object Context
//        managedObjectContext.parent = self.viewManagedContext
//        
//        return managedObjectContext
//    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        saveContext(context: viewManagedContext)
    }
    
    func saveContext (context: NSManagedObjectContext) {
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                    if let parentContext = context.parent {
                        self.saveContext(context: parentContext)
                    }
                } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    lazy var backgroundManagedContext: NSManagedObjectContext = {
//        return persistentContainer.newBackgroundContext()
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = viewManagedContext
        return backgroundContext
    }()
}

extension NSManagedObjectContext {
    func childManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        // Configure Managed Object Context
        managedObjectContext.parent = self
        return managedObjectContext
    }
}

