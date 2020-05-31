//
//  Schedule+CoreDataProperties.swift
//  GT
//
//  Created by Maksim Tochilkin on 30.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData


extension Schedule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        return NSFetchRequest<Schedule>(entityName: "Schedule")
    }

    @NSManaged public var name: String?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension Schedule {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ScheduleItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ScheduleItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
