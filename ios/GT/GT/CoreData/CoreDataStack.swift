//
//  CoreDataStack.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import CoreData
import Groot

class CoreDataStack {
    static let shared = CoreDataStack()
    
    var container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            print(error)
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
    }
    
    func newObject<T>(type: T.Type, _ config: ((T) -> Void)?) throws -> T where T: NSManagedObject {
        let object = T(context: container.viewContext)
        config?(object)
        try container.viewContext.save()
        return object
    }
    
    func fetch<T>(type: T.Type) throws -> [T] where T: NSManagedObject {
        let request = T.fetchRequest()
        let result = try container.viewContext.fetch(request) as? [T]
        return result ?? []
    }
    
    func delete(_ object: NSManagedObject) throws {
        container.viewContext.delete(object)
        try container.viewContext.save()
    }
    
    
    func insertCourses(_ courses: [[String: Any]], completion: @escaping (Bool) -> Void) {
        container.performBackgroundTask { context in
            do {
                for c in courses {
                    let course = try object(withEntityName: "Course", fromJSONDictionary: c, inContext: context) as! Course
                }
            } catch {
                print(error)
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                      print(error)
                }
            }
        }
    }
}
