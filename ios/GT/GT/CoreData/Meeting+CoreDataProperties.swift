//
//  Meeting+CoreDataProperties.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData


extension Meeting {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meeting> {
        return NSFetchRequest<Meeting>(entityName: "Meeting")
    }

    @NSManaged public var time: String?
    @NSManaged public var days: String?
    @NSManaged public var location: String?
    @NSManaged public var type: String?
    @NSManaged public var instructor: [String]?
    @NSManaged public var section: Section?

}
