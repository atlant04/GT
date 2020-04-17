//
//  Parser.swift
//  GT
//
//  Created by MacBook on 4/17/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import MTWeekView


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

    static func parseMeeting(meeting: Meeting) -> [MeetingEvent] {
        guard let time = meeting.time, let daysOfWeek = meeting.days else { return [] }
        guard let hyphen = time.firstIndex(of: "-") else { return [] }
        let start = time[..<hyphen]
        let endRange = time.index(hyphen, offsetBy: 2)...
        let end = time[endRange]

        let days = Array(daysOfWeek).compactMap { Day(character: $0) }

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        if let startDate = formatter.date(from: "2:00 pm"),
            let endDate = formatter.date(from: String(end)) {
            let startTime = Time(from: startDate)
            let endTime = Time(from: endDate)

            return days.map { MeetingEvent(type: meeting.type, name: meeting.section?.id, day: $0, start: startTime, end: endTime)}
        } else {
            return days.map { MeetingEvent(type: meeting.type, name: meeting.section?.id, day: $0, start: Time(hour: 12, minute: 0), end: Time(hour: 14, minute: 0))}
        }

    }


}
