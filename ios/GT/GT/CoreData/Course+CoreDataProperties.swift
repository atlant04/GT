//
//  Course+CoreDataProperties.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData


extension Course {

    static func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var id: String?
    @NSManaged public var gradeBasis: String?
    @NSManaged public var attributes: String?
    @NSManaged public var name: String?
    @NSManaged public var semester: String?
    @NSManaged public var fields: [String]?
    @NSManaged public var fullname: String?
    @NSManaged public var school: String?
    @NSManaged public var number: String?
    @NSManaged public var hours: String?
    @NSManaged public var identifier: String?
    @NSManaged public var allSections: Set<Section>

}

// MARK: Generated accessors for sections
extension Course {

    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: Section)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: Section)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)

}
