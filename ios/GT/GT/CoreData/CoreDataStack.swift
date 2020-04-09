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
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
    }
    
    func insertCourses(_ courses: [[String: Any]], completion: @escaping (Bool) -> Void) {
        container.performBackgroundTask { context in
            do {
                for course in courses {
                    let _ = try object(withEntityName: "Course", fromJSONDictionary: course, inContext: context) as! Course
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
