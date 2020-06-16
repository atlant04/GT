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
        container.loadPersistentStores { (_, _) in }
    }
    
    func newObject<T>(type: T.Type, config: ((T) -> Void)?) throws -> T? where T: NSManagedObject {
        let object = T(entity: T.entity(), insertInto: container.viewContext)
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
    
    @discardableResult
    func save() -> Error? {
        do {
            try container.viewContext.save()
        } catch {
            return error
        }
        return nil
    }
    
    
    func insertCourses(_ courses: [[String: Any]], completion: @escaping (Bool) -> Void) {
        container.performBackgroundTask { context in
            do {
                for c in courses {
                    try object(withEntityName: "Course", fromJSONDictionary: c, inContext: context) as! Course
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
    
    func loadData<T>(sortedBy: String...) -> NSFetchedResultsController<T>? where T: NSManagedObject {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: T.entity().name ?? "")
        request.sortDescriptors = sortedBy.map { NSSortDescriptor(key: $0, ascending: true) }
        let controller = NSFetchedResultsController<T>(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: sortedBy.first, cacheName: nil)
        do {
            try controller.performFetch()
            return controller
        } catch {
            print(error)
            return nil
        }
    }
    
    func downloadData(completion: @escaping (Bool) -> Void) {
        ServerManager.shared.getCourses() { dict in
            self.insertCourses(dict) { success in
                completion(success)
            }
        }
    }
    
    var description: NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.url = currentTermUrl
        return description
    }
    
    var currentTermUrl: URL? {
        NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(AppConstants.shared.currentTerm).sqlite")
    }
    
    var currentStore: NSPersistentStore? {
        guard let url = currentTermUrl else { return nil }
        return container.persistentStoreCoordinator.persistentStore(for: url)
    }
    
}
