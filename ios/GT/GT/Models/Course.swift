//
//  Course.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit

struct Course: Decodable, Hashable {

    let id: String
    let gradeBasis: String
    let attributes: String?
    let name: String
    let semester: String
    let fields: [String]
    let fullname: String
    var school: School
    let number: String
    let hours: String
    let identifier: String
    let sections: [Section]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case attributes = "course_attributes"
        case gradeBasis = "grade_basis"
        case name, semester, fields, fullname, school, number, hours, identifier, sections
    }

    struct Section: Decodable, Hashable {
        let id: String
        let crn: String
        let instructors = [String]()
        let meetings = [Meeting]()
        enum CodingKeys: String, CodingKey {
            case id = "section_id", crn, instructors, meetings
        }
    }

    struct Meeting: Decodable, Hashable {
        let time: String?
        let days: String?
        let location: String?
        let type: String
        let instructor: [String]
    }

    enum School: String, Decodable, CaseIterable {
        case CS = "CS"
        case PHYS = "PHYS"
        case INTA = "INTA"
        case MATH = "MATH"

        var color: UIColor {
            get {
                switch self {
                case .CS:
                    return .systemBlue
                case .PHYS:
                    return .systemPink
                case .INTA:
                    return .systemYellow
                default:
                    return .systemRed
                }
            }
        }
    }
}


