//
//  Course+CoreDataClass.swift
//  GT
//
//  Created by Maksim Tochilkin on 26.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//
//

import Foundation
import CoreData
import ObjectMapper

@objc(Course)
public class Course: NSManagedObject, Mappable {
    var sections: [Section] {
        return Array(allSections)
    }
    
    var schoolId: School? {
        if let school = school {
            return School(rawValue: school)
        }
        return nil
    }
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        let context = CoreDataStack.shared.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        super.init(entity: entity, insertInto: context)
    }
    
    public required init?(map: Map) {
        let context = CoreDataStack.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        super.init(entity: entity, insertInto: context)
        self.mapping(map: map)
    }
    
    
    public func mapping(map: Map) {
        id <- map["_id"]
        gradeBasis <- map["grade_basis"]
        attributes <- map["attributes"]
        name <- map["name"]
        semester <- map["semester"]
        fields <- map["fields"]
        fullname <- map["fullname"]
        school <- map["school"]
        number <- map["number"]
        hours <- map["hours"]
        identifier <- map["identifier"]
        allSections <- map["sections"]
    }
}

enum School: String, Decodable, CaseIterable {
    case CS = "CS"
    case PHYS = "PHYS"
    case INTA = "INTA"
    case MATH = "MATH"
    case NONE = "None"

    var color: UIColor {
        get {
            switch self {
            case .CS:
                return .systemBlue
            case .PHYS:
                return .systemPink
            case .INTA:
                return .systemYellow
            case .MATH:
                return .systemGreen
            default:
                return .systemRed
            }
        }
    }
}


