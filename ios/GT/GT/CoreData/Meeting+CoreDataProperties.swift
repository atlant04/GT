//
//  Meeting+CoreDataProperties.swift
//  
//
//  Created by Maksim Tochilkin on 29.05.2020.
//
//

import Foundation
import CoreData


extension Meeting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meeting> {
        return NSFetchRequest<Meeting>(entityName: "Meeting")
    }

    @NSManaged public var days: String?
    @NSManaged public var events: [MeetingObject]?
    @NSManaged public var instructor: [String]?
    @NSManaged public var location: String?
    @NSManaged public var time: String?
    @NSManaged public var type: String?
    @NSManaged public var section: Section?

}
