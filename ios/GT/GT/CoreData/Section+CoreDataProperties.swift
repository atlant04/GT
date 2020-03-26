//
//  Section+CoreDataProperties.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData


extension Section {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section> {
        return NSFetchRequest<Section>(entityName: "Section")
    }

    @NSManaged public var id: String?
    @NSManaged public var crn: String?
    @NSManaged public var instructors: [String]?
    @NSManaged public var identifier: String?
    @NSManaged public var course: Course?
    @NSManaged public var allMeetings: Set<Meeting>

}

// MARK: Generated accessors for meetings
extension Section {

    @objc(addMeetingsObject:)
    @NSManaged public func addToMeetings(_ value: Meeting)

    @objc(removeMeetingsObject:)
    @NSManaged public func removeFromMeetings(_ value: Meeting)

    @objc(addMeetings:)
    @NSManaged public func addToMeetings(_ values: NSSet)

    @objc(removeMeetings:)
    @NSManaged public func removeFromMeetings(_ values: NSSet)

}
