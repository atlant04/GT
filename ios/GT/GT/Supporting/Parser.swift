//
//  Parser.swift
//  GT
//
//  Created by MacBook on 4/17/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import MTWeekView
import SwiftDate


struct Parser {
    
    
    static func parseMeeting(meeting: Meeting) -> [MeetingEvent] {
        guard let time = meeting.time, let daysOfWeek = meeting.days else { return [] }
        let times = time.split(separator: "-")
        guard !times.isEmpty else { return [] }

        let days = Array(daysOfWeek).compactMap { Day(character: $0) }
        let strings = times.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let start = dateFormatter.date(from: strings[0]),
            let end = dateFormatter.date(from: strings[1]) {
            return days.map {
                MeetingEvent(type: meeting.type,
                             name: meeting.section?.id,
                             day: $0,
                             start: Time(from: start),
                             end: Time(from: end))
            }
        }

        return []
    }
    
    static func events(for meeting: Meeting) -> [MeetingEvent] {
        return Parser.parseMeeting(meeting: meeting)
    }
    
    static func events(for section: Section, withColor: String? = nil) -> [MeetingEvent] {
        var eventss = section.meetings?.flatten { events(for: $0) } ?? []
        if let color = withColor {
            for i in 0..<eventss.count {
                eventss[i].setColor(color)
            }
        }
        return eventss
    }
    
    static func events(for course: Course) -> [MeetingEvent] {
        course.sections?.flatten { events(for: $0) } ?? []
    }
    
    static func events(for schedule: Schedule) -> [MeetingEvent] {
        schedule.items?.flatten { events(for: $0.course) } ?? []
    }
    
    static func events(scheduleWithColor: Schedule) -> [MeetingEvent] {
        scheduleWithColor.items?.flatten { events(for: $0) } ?? []
    }
    
    static func events(for item: ScheduleItem, onlySelected: Bool = false) -> [MeetingEvent] {
        var eventss = (onlySelected ? item.selectedSections?.flatten { events(for: $0)} : events(for: item.course)) ?? []
        for i in 0..<eventss.count {
            eventss[i].setColor(item.color)
        }
        return eventss
    }
    
    
}


extension Collection {
    func flatten<Mapped>(_ map: (Self.Element) throws -> [Mapped]) rethrows -> [Mapped] {
        try self.compactMap(map).reduce([], +)
    }
}
