//
//  Storage.swift
//  GT
//
//  Created by Maksim Tochilkin on 27.07.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import RealmSwift

class Storage {
    static let shared = Storage()
    fileprivate let realm: Realm
    
    private init() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 4,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        realm = try! Realm()
        print(realm.configuration.fileURL)
    }
    
    func fetch<T>(_ type: T.Type) -> [T] where T: Persistable {
        let result = realm.objects(T.ManagedObject.self)
        return result.map { T(managedObject: $0) }
    }
    
    func add<T>(_ item: T) where T: Persistable {
        self.write {
            realm.add(item.managedObject, update: .all)
        }
    }
    
    private func write(_ block: () -> ()) {
        do {
            try realm.write { block() }
        } catch {
            print("[REALM] Error in \(#function) -> \(error)")
        }
    }
    
    public func downloadCourses(_ completion: @escaping (Results<CourseMO>) -> Void) {
        API.getTestCourses(size: 1000) { [unowned self] data in
            do {
                let courses = try JSONDecoder().decode([Course].self, from: data)
                try self.realm.write {
                    self.realm.add(courses.managedObjects, update: .all)
                }
                let results = self.realm.objects(CourseMO.self)
                completion(results)
            } catch {
                print("[REALM] Error in \(#function) -> \(error)")
            }
        }
    }
    
}


@propertyWrapper
class Fetched<Object> where Object: Persistable {
    private var results: Results<Object.ManagedObject>
    let realm = Storage.shared.realm
    private var storage: [Object]
    private var token: NotificationToken?
    
    init() {
        results = realm.objects(Object.ManagedObject.self)
        storage = results.map(Object.init(managedObject:))
        
        token = results.observe { [unowned self] change in
            switch change {
            case .update(let newResults, _, _, _):
                self.storage = Array(newResults).map(Object.init(managedObject:))
            default:
                break
            }
        }
    }
    
    var wrappedValue: [Object] {
        get {
            storage
        }
        set {
            self.storage = newValue
        }
    }
    
    var projectedValue: Results<Object.ManagedObject> {
        get {
            return results
        }
        
        set {
            self.results = newValue
            self.storage = results.map(Object.init(managedObject:))
        }
    }
}
