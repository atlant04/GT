//
//  Models.swift
//  ScrollPickerTest
//
//  Created by Maksim Tochilkin on 27.07.2020.
//

import Foundation
import UIKit
import RealmSwift
import MTWeekView

extension Collection where Element: Persistable {
    var managedObjects: [Element.ManagedObject] {
        return self.map(\.managedObject)
    }
}


public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    var managedObject: ManagedObject { get }
}

struct Schedule: Hashable {
    var name: String
    var items: [ScheduleItem]
}

extension Schedule: Persistable {
    init(managedObject: ScheduleMO) {
        self.name = managedObject.name
        self.items = managedObject.items.map(ScheduleItem.init(managedObject: ))
    }
    
    var managedObject: ScheduleMO {
        let schedule = ScheduleMO()
        schedule.name = self.name
        schedule.items.append(objectsIn: self.items.managedObjects)
        return schedule
    }
}

class ScheduleMO: Object {
    @objc dynamic var name: String = ""
    let items = List<ScheduleItemMO>()
    
    override class func primaryKey() -> String? {
        "name"
    }
}

struct ScheduleItem: Hashable {
    var color: UIColor = .clear
    var selectedSections: Set<Section>
    var course: Course?
}

extension ScheduleItem: Persistable {
    init(managedObject: ScheduleItemMO) {
        if let hex = managedObject.color {
            self.color = UIColor(hex: hex) ?? .clear
        }
        self.selectedSections = Set(managedObject.selectedSections.map { Section(managedObject: $0) })
        
        if let course = managedObject.course {
            self.course = Course(managedObject: course)
        }
    }
    
    var managedObject: ScheduleItemMO {
        let item = ScheduleItemMO()
        item.color = self.color.hexString
        item.selectedSections.append(objectsIn: self.selectedSections.managedObjects)
        item.course = self.course?.managedObject
        return item
    }
}

class ScheduleItemMO: Object {
    @objc dynamic var color: String?
    let selectedSections = List<SectionMO>()
    @objc dynamic var course: CourseMO?

}


struct Course: Codable, Persistable, Identifiable, Hashable {
    let id: String
    let identifier: String
    let fullname: String
    let gradeBasis: String
    let shours: String
    let name: String
    let number: String
    let ssemester: String
    var sections: [Section]?
    var restrictions: RestrictionArray?
    var prerequisites: Prerequisite?
    var attributes: String?
    var school: String
    
    var hours: [Int] {
        let strs = shours.split(separator: " ")
        return strs.compactMap { Double($0) }.map(Int.init)
    }
    
    var semester: AppConstants.Term {
        return AppConstants.Term(rawValue: self.ssemester)!
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id", identifier, fullname, gradeBasis = "grade_basis", shours = "hours", name, number, ssemester = "semester", sections, restrictions, prerequisites, attributes = "course_attributes", school
    }
    
    init(managedObject: CourseMO) {
        self.id = managedObject.id
        self.identifier = managedObject.identifier
        self.fullname = managedObject.fullname
        self.gradeBasis = managedObject.gradeBasis
        self.shours = managedObject.shours
        self.name = managedObject.name
        self.number = managedObject.number
        self.ssemester = managedObject.ssemester
        self.attributes = managedObject.attributes
        self.school = managedObject.school
        self.sections = managedObject.sections.map { Section(managedObject: $0) }
        if let res = managedObject.restrictions {
            self.restrictions = RestrictionArray(managedObject: res)
        }
        if let req = managedObject.prerequisites {
            self.prerequisites = Prerequisite(managedObject: req)
        }
    }
    
    var managedObject: CourseMO {
        let course = CourseMO()
        course.id = self.id
        course.identifier = self.identifier
        course.fullname = self.fullname
        course.gradeBasis = self.gradeBasis
        course.shours = self.shours
        course.name = self.name
        course.number = self.number
        course.school = self.school
        course.attributes = self.attributes
        course.ssemester = self.ssemester
        if let sections = self.sections?.compactMap({ $0.managedObject }) {
            course.sections.append(objectsIn: sections)
        }
        course.restrictions = restrictions?.managedObject
        course.prerequisites = prerequisites?.managedObject
        return course
    }
    
    var events: [MeetingEvent]? {
        guard let allEvents = self.sections?.flatten({ $0.events }) else { return nil }
        return allEvents
    }
}

class CourseMO: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var identifier: String = ""
    @objc dynamic var fullname: String = ""
    @objc dynamic var gradeBasis: String = ""
    @objc dynamic var shours: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var number: String = ""
    @objc dynamic var ssemester: String = ""
    @objc dynamic var school: String = ""
    @objc dynamic var attributes: String?
    @objc dynamic var restrictions: RestrictionArrayMO?
    @objc dynamic var prerequisites: PrerequisiteMO?
    let sections = List<SectionMO>()
    
    var hours: [Int] {
        let strs = shours.split(separator: " ")
        return strs.compactMap { Double($0) }.map(Int.init)
    }
    
    var semester: AppConstants.Term {
        return AppConstants.Term(rawValue: self.ssemester)!
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

struct Section: Codable, Hashable {

    let id: String
    let crn: String
    let meetings: [Meeting]?
    let instructors: [String]?
    var tracked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "section_id", crn, meetings, instructors
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.crn == rhs.crn
    }
    
    var events: [MeetingEvent]? {
        guard let allEvents = self.meetings?.flatten({ $0.events }) else { return nil }
        return allEvents
    }
    
}

extension Section: Persistable {
    init(managedObject: SectionMO) {
        self.id = managedObject.id
        self.crn = managedObject.crn
        self.tracked = managedObject.tracked
        self.meetings = managedObject.meetings.compactMap { Meeting(managedObject: $0) }
        self.instructors = Array(managedObject.instructors)
    }
    
    var managedObject: SectionMO {
        let section = SectionMO()
        section.id = self.id
        section.crn = self.crn
        section.tracked = self.tracked
        if let meetings = self.meetings?.compactMap({ $0.managedObject }) {
            section.meetings.append(objectsIn: meetings)
        }
        section.instructors.append(objectsIn: self.instructors ?? [])
        return section
    }
}



class SectionMO: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var crn: String = ""
    @objc dynamic var tracked: Bool = false
    let meetings = List<MeetingMO>()
    let instructors = List<String>()
    private let courses = LinkingObjects(fromType: CourseMO.self, property: "sections")
    var course: CourseMO? {
        return courses.first
    }
    
    override class func primaryKey() -> String? {
        return "crn"
    }
}

struct Meeting: Codable, Persistable, Hashable {
    var time: String?
    var days: String?
    var location: String?
    let type: String
    let instructor: [String]
    
    static var formatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
    
    var times: (start: Date, end: Date)? {
        guard let times = time?.split(separator: "-"),
              !times.isEmpty
        else { return nil }
        
        let strings = times.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
            
        if let start = Meeting.formatter.date(from: strings[0]),
           let end = Meeting.formatter.date(from: strings[1]) {
            return (start, end)
        }
        
        return nil
    }
    
    init(managedObject: MeetingMO) {
        self.time = managedObject.time
        self.days = managedObject.days
        self.location = managedObject.location
        self.type = managedObject.type
        self.instructor = Array(managedObject.instructor)
    }
    
    var managedObject: MeetingMO {
        let meeting = MeetingMO()
        meeting.time = self.time
        meeting.days = self.days
        meeting.location = self.location
        meeting.type = self.type
        meeting.instructor.append(objectsIn: self.instructor)
        return meeting
    }

    var events: [MeetingEvent]? {
        guard let days = self.days else { return nil }
        var arr = [MeetingEvent]()
        
        for day in days {
            guard let start = self.times?.start, let end = self.times?.end else { continue }
            let event = MeetingEvent(day: Day(character: day), start: Time(from: start), end: Time(from: end))
            arr.append(event)
        }
        
        return arr
    }
}

class MeetingMO: Object {
    @objc dynamic var time: String?
    @objc dynamic var days: String?
    @objc dynamic var location: String?
    @objc dynamic var type: String = ""
    let instructor = List<String>()

}

struct RestrictionArray: Codable, Persistable, Hashable {
    
    var restrictions: [Restriction] = []
    
    enum Field: String, CodingKey, Codable, CaseIterable {
        case Campuses, Classifications, Levels, none
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Field.self)
        for key in Field.allCases {
            if var res = try? container.decodeIfPresent(Restriction.self, forKey: key) {
                res.type = key
                restrictions.append(res)
            }
        }
    }
    
    init(managedObject: RestrictionArrayMO) {
        self.restrictions = managedObject.restrictions.map { Restriction(managedObject: $0) }
    }
    
    var managedObject: RestrictionArrayMO {
        let arr = RestrictionArrayMO()
        arr.restrictions.append(objectsIn: restrictions.map { $0.managedObject })
        return arr
    }
}

struct Restriction: Codable, Persistable, Hashable {
    var type: RestrictionArray.Field = .none
    let positive: Bool
    let requirements: [String]
    
    enum CodingKeys: String, CodingKey {
        case positive, requirements
    }
    
    init(managedObject: RestrictionMO) {
        self.positive = managedObject.positive
        self.requirements = Array(managedObject.requirements)
        self.type = RestrictionArray.Field(rawValue: managedObject.type)!
    }
    
    var managedObject: RestrictionMO {
        let res = RestrictionMO()
        res.positive = self.positive
        res.requirements.append(objectsIn: self.requirements)
        res.type = self.type.rawValue
        return res
    }
}

class RestrictionArrayMO: Object {
    var restrictions = List<RestrictionMO>()
}

class RestrictionMO: Object {
    @objc dynamic var positive: Bool = false
    @objc dynamic var type: String = ""
    let requirements = List<String>()
}

struct Prerequisite: Codable, Persistable, Hashable {
    let type: PrereqType
    var courses: [String] = []
    var additional: [Prerequisite] = []
    
    enum PrereqType: String, Codable {
        case and, or
    }
    
    enum CodingKeys: String, CodingKey {
        case type, courses
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        self.type = PrereqType(rawValue: type)!
        var arr = try container.nestedUnkeyedContainer(forKey: .courses)
        
        while !arr.isAtEnd {
            if let course = try? arr.decodeIfPresent(String.self) {
                self.courses.append(course)
            }
            
            if let req = try? arr.decodeIfPresent(Prerequisite.self) {
                self.additional.append(req)
            }
        }
        
    }
    
    init(managedObject: PrerequisiteMO) {
        self.type = PrereqType(rawValue: managedObject.type)!
        self.courses = Array(managedObject.courses)
        self.additional = Array(managedObject.additional.map { Prerequisite(managedObject: $0)})
    }
    
    var managedObject: PrerequisiteMO {
        let req = PrerequisiteMO()
        req.courses.append(objectsIn: self.courses)
        req.type = self.type.rawValue
        req.additional.append(objectsIn: self.additional.map { $0.managedObject })
        return req
    }
}

class PrerequisiteMO: Object {
    @objc dynamic var type: String = ""
    let courses = List<String>()
    let additional = List<PrerequisiteMO>()
}


extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription) -> \(context.codingPath)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}

// MARK: MTWeekView Extensions

public struct MeetingEvent: Codable, Event {
    public var id: UUID = UUID()

    public var type: String?
    public var name: String?
    public var day: Day
    public var start: Time
    public var end: Time
    public var color: String?
    
    mutating func setName(name: String?) {
        self.name = name
    }
    
    mutating func setColor(_ color: String) {
        self.color = color
    }
}

@propertyWrapper
enum Lazy<Value> {
    case uninitialized(() -> Value)
    case initialized(Value)

    init(wrappedValue: @autoclosure @escaping () -> Value) {
        self = .uninitialized(wrappedValue)
    }

    var wrappedValue: Value {
        mutating get {
            switch self {
            case .uninitialized(let initializer):
                let value = initializer()
                self = .initialized(value)
                return value
            case .initialized(let value):
                return value
            }
        }
        set {
            self = .initialized(newValue)
        }
    }
}
