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
    static func parseEvents(course: Course) -> [MeetingEvent] {
        var result = [MeetingEvent]()

        guard let sections = course.sections as? Set<Section> else { return result }

        for section in sections {
            if let meetings = section.meetings as? Set<Meeting> {
                let events = meetings.flatMap(parseMeeting)
                print(events)
                result.append(contentsOf: events)
            }
        }
        return result
    }
    
//    static parseSection(_ section: Section) -> [MeetingEvent] {
//        var result = [MeetingEvent]()
//    }

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
}
