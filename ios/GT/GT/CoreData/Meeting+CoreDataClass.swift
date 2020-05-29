//
//  Meeting+CoreDataClass.swift
//  
//
//  Created by Maksim Tochilkin on 28.05.2020.
//
//

import Foundation
import CoreData


public class Meeting: NSManagedObject {
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        events = Parser.parseMeeting(meeting: self).map { MeetingObject(event: $0) }
    }
}
