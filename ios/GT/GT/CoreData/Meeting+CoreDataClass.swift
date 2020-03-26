//
//  Meeting+CoreDataClass.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(Meeting)
public class Meeting: NSManagedObject, Mappable {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        let context = CoreDataStack.shared.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        super.init(entity: entity, insertInto: context)
    }

    public required init?(map: Map) {
        let context = CoreDataStack.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Meeting", in: context)!
        super.init(entity: entity, insertInto: context)
        self.mapping(map: map)
    }
    
    public func mapping(map: Map) {
           time <- map["time"]
           days <- map["days"]
           location <- map["location"]
           type <- map["type"]
           instructor <- map["instructor"]
       }
}
