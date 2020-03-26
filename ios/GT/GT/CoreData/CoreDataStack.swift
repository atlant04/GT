//
//  CoreDataStack.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSPersistentContainer {
    static let shared = CoreDataStack()
    
    private init() {
        let modelUrl = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelUrl)!
        super.init(name: "CoreDataStack", managedObjectModel: model)
        self.loadPersistentStores { (description, error) in
            print(error)
        }
    }
    
    func fetchCourses(request: NSFetchRequest<Course>? = nil) -> [Course] {
        let request = request ?? NSFetchRequest<Course>(entityName: "Course")
        
        do {
            return try self.viewContext.fetch(request)
        } catch {
            print(error)
            return []
        }
    }
    
    
    func fetchCourses(by school: String) -> [Course] {
        let request = NSFetchRequest<Course>(entityName: "Course")
        request.predicate = NSPredicate(format: "school == '\(school)'")
        return fetchCourses(request: request)
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}
