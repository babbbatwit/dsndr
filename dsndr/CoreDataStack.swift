//
//  CoreDataStack.swift
//  dsndr
//
//  Created by Brenton Babb on 1/29/21.
//

import Foundation
import CoreData

class CoreDataStack {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "dsndr")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var context: NSManagedObjectContext { return persistentContainer.viewContext }
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
