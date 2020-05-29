//
//  Meeting+CoreDataProperties.swift
//  
//
//  Created by Maksim Tochilkin on 28.05.2020.
//
//

import Foundation
import CoreData


extension Meeting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meeting> {
        return NSFetchRequest<Meeting>(entityName: "Meeting")
    }

    @NSManaged public var days: String?
    @NSManaged public var instructor: [String]?
    @NSManaged public var location: String?
    @NSManaged public var time: String?
    @NSManaged public var type: String?
    @NSManaged public var events: [MeetingObject]?
    @NSManaged public var section: Section?

    public var all: [MeetingEvent]? {
        return events?.compactMap { obj in
            MeetingEvent(id: UUID(), type: obj.type, name: obj.name, day: obj.day, start: obj.start, end: obj.end)
        }
    }
}


extension Section {
    var allEvents: [MeetingEvent]? {
        (meetings as? Set<Meeting>)?.compactMap { $0.all }.reduce([], +)
    }
}
