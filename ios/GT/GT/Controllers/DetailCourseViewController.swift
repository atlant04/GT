//
//  DetailCourseViewController.swift
//  GT
//
//  Created by MacBook on 3/17/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit
import JZCalendarWeekView

class DetailCourseViewController: UIViewController, MTWeekViewDataSource {

    var calendar: CalendarView!
    var course: Course!
    var events: [Event]?

    override func viewDidLoad() {
        super.viewDidLoad()
        TimeZone.ReferenceType.default = TimeZone(abbreviation: "UTC")!
        parseEvents()
        calendar = CalendarView(frame: view.bounds)
        calendar.dataSource = self
        view.addSubview(calendar)
    }

    func parseEvents() {
        guard let sections = course.sections else { return }
        let meetings = sections.flatMap { $0.meetings }
        print(meetings)
        let events = meetings.flatMap { parseMeeting(meeting: $0) }
        self.events = events
    }

    func parseMeeting(meeting: Course.Meeting) -> [Event] {
        guard let hyphen = meeting.time.firstIndex(of: "-") else { return [] }
        let start = meeting.time[..<hyphen]
        let endRange = meeting.time.index(hyphen, offsetBy: 2)...
        let end = meeting.time[endRange]

        let days = Array(meeting.days).compactMap { Event.DayOfWeek(rawValue: $0) }

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        if let startDate = formatter.date(from: String(start)),
            let endDate = formatter.date(from: String(end)) {
            return days.map { Event(meeting: meeting, startDate: startDate, endDate: endDate, dayOfWeek: $0)}
        } else {
            return []
        }

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendar)
    }

    func calendar(eventsForDate date: Date) -> [JZBaseEvent] {
        guard let events = self.events else { return [] }
        let day = Calendar.current.dateComponents([.weekday], from: date)
        let eventsForDay =  events.filter({ (event) -> Bool in
            return event.dayOfWeek.dayIndex == day.weekday
        })
        return eventsForDay
    }


}

class CalendarView: MTWeekView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func registerViewClasses() {
        super.registerViewClasses()
        //self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: EventCell.reuseIdentifier)
        self.collectionView.register(EventCell.self, forCellWithReuseIdentifier: EventCell.reuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.reuseIdentifier, for: indexPath) as! EventCell
        let event = getCurrentEvent(with: indexPath) as! Event
        cell.update(event: event)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = getCurrentEvent(with: indexPath)
        print(event?.startDate)
    }
}


class Event: JZBaseEvent {
    let dayOfWeek: DayOfWeek
    let meeting: Course.Meeting

    init(meeting: Course.Meeting, startDate: Date, endDate: Date, dayOfWeek: DayOfWeek ) {
        self.dayOfWeek = dayOfWeek
        self.meeting = meeting
        super.init(id: "None", startDate: startDate, endDate: endDate)
    }

    override func copy(with zone: NSZone?) -> Any {
        return Event(meeting: meeting, startDate: startDate, endDate: endDate, dayOfWeek: dayOfWeek)
    }

    enum DayOfWeek: Character, CaseIterable {
        case Monday = "M"
        case Tuesday = "T"
        case Wednesday = "W"
        case Thurday = "R"
        case Friday = "F"

        var dayIndex: Int {
            return (DayOfWeek.allCases.firstIndex(of: self) ?? 0) + 2
        }
    }
}


class EventCell: UICollectionViewCell {
    static let reuseIdentifier: String = "eventCell"

    func update(event: Event) {
        label.text = Calendar.current.dateComponents([.hour, .minute], from: event.startDate).description
    }

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemBackground
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .caption1), maximumPointSize: 12)
        return label
    }()

    let border: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        contentView.addSubview(label)
        contentView.addSubview(border)
        setupBasic()
        NSLayoutConstraint.activate([
            border.widthAnchor.constraint(equalToConstant: 2),
            border.topAnchor.constraint(equalTo: contentView.topAnchor),
            border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: border.trailingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Plz stop using storyboards")
    }

    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        self.backgroundColor = .systemTeal
    }
}



protocol MTWeekViewDataSource {
    func calendar(eventsForDate date: Date) -> [JZBaseEvent]
}

class MTWeekView: JZBaseWeekView {

    var week: [Date] = Date.getCurrentWeek()

    var dataSource: MTWeekViewDataSource? {
        didSet {
            setupCalendar()
            self.collectionView.reloadData()
        }
    }

    func setupCalendar() {
        let allEvents = getAllEventsForCurrentWeek()
        let setDate = week.first ?? Date()
        let range = (week.first, week.last)
        self.setupCalendar(numOfDays: 5, setDate: setDate, allEvents: allEvents, scrollType: .pageScroll, firstDayOfWeek: .Monday, currentTimelineType: .page, visibleTime: Date(), scrollableRange: range)
    }

    func getAllEventsForCurrentWeek() -> [Date: [JZBaseEvent]] {
        var resultingEvents = [Date: [JZBaseEvent]]()
        for day in week {
            let dayEvents = dataSource?.calendar(eventsForDate: day)
            resultingEvents[day] = dayEvents
        }
        return resultingEvents
    }


}
