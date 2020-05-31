//
//  ScheduleItem+CoreDataProperties.swift
//  GT
//
//  Created by Maksim Tochilkin on 30.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData


extension ScheduleItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleItem> {
        return NSFetchRequest<ScheduleItem>(entityName: "ScheduleItem")
    }

    @NSManaged public var color: String?
    @NSManaged public var courses: NSSet?
    @NSManaged public var selectedSections: NSSet?

}

// MARK: Generated accessors for courses
extension ScheduleItem {

    @objc(addCoursesObject:)
    @NSManaged public func addToCourses(_ value: Course)

    @objc(removeCoursesObject:)
    @NSManaged public func removeFromCourses(_ value: Course)

    @objc(addCourses:)
    @NSManaged public func addToCourses(_ values: NSSet)

    @objc(removeCourses:)
    @NSManaged public func removeFromCourses(_ values: NSSet)

}

// MARK: Generated accessors for selectedSections
extension ScheduleItem {

    @objc(addSelectedSectionsObject:)
    @NSManaged public func addToSelectedSections(_ value: Section)

    @objc(removeSelectedSectionsObject:)
    @NSManaged public func removeFromSelectedSections(_ value: Section)

    @objc(addSelectedSections:)
    @NSManaged public func addToSelectedSections(_ values: NSSet)

    @objc(removeSelectedSections:)
    @NSManaged public func removeFromSelectedSections(_ values: NSSet)

}
