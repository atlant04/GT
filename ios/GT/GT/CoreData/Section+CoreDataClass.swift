//
//  Section+CoreDataClass.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(Section)
public class Section: NSManagedObject, Mappable {
    
    var meetings: [Meeting] {
        return Array(allMeetings)
    }
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        let context = CoreDataStack.shared.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        super.init(entity: entity, insertInto: context)
    }
    
    public required init?(map: Map) {
        let context = CoreDataStack.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Section", in: context)!
        super.init(entity: entity, insertInto: context)
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
           id <- map["section_id"]
           crn <- map["crn"]
           instructors <- map["instructors"]
           allMeetings <- map["meetings"]
           identifier <- map["parentId"]
       }

}
