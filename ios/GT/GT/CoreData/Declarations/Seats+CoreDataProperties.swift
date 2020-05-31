//
//  Seats+CoreDataProperties.swift
//  GT
//
//  Created by Maksim Tochilkin on 29.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData


extension Seats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Seats> {
        return NSFetchRequest<Seats>(entityName: "Seats")
    }

    @NSManaged public var actual: Int64
    @NSManaged public var actualWL: Int64
    @NSManaged public var capacity: Int64
    @NSManaged public var capacityWL: Int64
    @NSManaged public var remaining: Int64
    @NSManaged public var remainingWL: Int64
    @NSManaged public var section: Section?

}
