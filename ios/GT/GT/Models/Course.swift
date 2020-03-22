//
//  Course.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import ObjectMapper
import UIKit

struct Course: Mappable, Hashable {
    
    init?(map: Map) { }

    var id: String?
    var gradeBasis: String?
    var attributes: String?
    var name: String?
    var semester: String?
    var fields: [String]?
    var fullname: String?
    var school: School?
    var number: String?
    var hours: String?
    var identifier: String?
    var sections: [Section]?

//    init(map: Map) throws {
//        id = try map.value("_id") ?? "None"
//        gradeBasis = try map.value("grade_basis") ?? "None"
//        attributes = try map.value("attributes") ?? "None"
//        name = try map.value("name") ?? "None"
//        semester = try map.value("semester") ?? "None"
//        fields = try map.value("fields") ?? []
//        fullname = try map.value("fullname") ?? "None"
//        school = try map.value("school") ?? .NONE
//        number = try map.value("number") ?? "None"
//        hours = try map.value("hours") ?? "None"
//        identifier = try map.value("identifier") ?? "None"
//        sections = try? map.value("sections")
//    }
    
    mutating func mapping(map: Map) {
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
        sections <- map["sections"]
    }

    struct Section: Mappable, Hashable {
        init?(map: Map) { }
        
        var id: String?
        var crn: String?
        var instructors: [String]?
        var meetings: [Meeting]?

//        init(map: Map) throws {
//            id = try map.value("section_id") ?? "None"
//            crn = try map.value("crn") ?? "None"
//            instructors = try map.value("instructors") ?? []
//            meetings = try map.value("meetings") ?? []
//        }
        
        mutating func mapping(map: Map) {
            id <- map["section_id"]
            crn <- map["crn"]
            instructors <- map["instructors"]
            meetings <- map["meetings"]
        }

    }

    struct Meeting: Mappable, Hashable {
        init?(map: Map) { }
        
        var time: String?
        var days: String?
        var location: String?
        var type: String?
        var instructor: [String]?

//        init(map: Map) throws {
//            time = try map.value("time") ?? "None"
//            days = try map.value("days") ?? "None"
//            location = try map.value("location") ?? "None"
//            type = try map.value("type") ?? "None"
//            instructor = try map.value("instructor") ?? []
//        }
        
        mutating func mapping(map: Map) {
            time <- map["time"]
            days <- map["days"]
            location <- map["location"]
            type <- map["type"]
            instructor <- map["instructor"]
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
}


