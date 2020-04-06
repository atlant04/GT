//
//  DetailViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit
import MTWeekView
import SwiftUI

class DetailViewController: UIViewController, MTWeekViewDataSource {
    
    var course: Course!
    var tableView: UITableView!
    var weekView: MTWeekView!
    var events: [Section: [Event]] = [:]
    var firstMeeting: Time = Time(hour: 8, minute: 0)
    var lastMeeting: Time = Time(hour: 20, minute: 0)
    var selectedSection: Section?
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Track", style: .plain, target: self, action: #selector(trackButtonTapped))
        navigationItem.title = course.identifier
        parseEvents()
        print(events)
        
        weekView = MTWeekView(frame: view.bounds, configuration: LayoutConfiguration())
        weekView.translatesAutoresizingMaskIntoConstraints = false
        weekView.dataSource = self
        weekView.registerCell(of: MeetingCell.self)
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.contentSize = CGSize(width: view.bounds.width, height: 200)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        
        view.addSubview(tableView)
        view.addSubview(weekView)
        
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension

        
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        var stack: UIStackView!
        stack = UIStackView(arrangedSubviews: [tableView, pickerView, weekView])
        stack.axis = .vertical
        
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        ])
        
    }
    
    @objc func trackButtonTapped() {
        NotificationCenter.default.post(name: .newTrackRequest, object: selectedSection)
    }
    
    func parseEvents() {
        guard let sections = course.sections as? Set<Section> else { return }
        for section in sections {
            var events: [Event] = []
            if let meetings = section.meetings as? Set<Meeting> {
                events = meetings.flatMap(parseMeeting)
            }
            self.events[section] = events
        }
    }
    
    func weekView(_ weekView: MTWeekView, eventsForDay day: Day) -> [Event] {
        if let section = selectedSection, let events = self.events[section] {
            return events.filter { $0.day == day }
        }
        return Array(events.values.joined()).filter { $0.day == day }
    }
    
    func hourRangeForWeek(_ weekView: MTWeekView) -> (start: Time, end: Time) {
        return (start: firstMeeting, end: lastMeeting)
    }
    
    
    func parseMeeting(meeting: Meeting) -> [MeetingEvent] {
        guard let time = meeting.time, let daysOfWeek = meeting.days else { return [] }
        guard let hyphen = time.firstIndex(of: "-") else { return [] }
        let start = time[..<hyphen]
        let endRange = time.index(hyphen, offsetBy: 2)...
        let end = time[endRange]
        
        let days = Array(daysOfWeek).compactMap { Day(character: $0) }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        //formatter.timeZone = TimeZone(abbreviation: "UTC")
        if let startDate = formatter.date(from: String(start)),
            let endDate = formatter.date(from: String(end)) {
            let startTime = Time(from: startDate)
            let endTime = Time(from: endDate)
            print(time)
            print(startTime)
            
            return days.map { MeetingEvent(identifier: course.identifier ?? "TBD", day: $0, start: startTime, end: endTime)}
        } else {
            return []
        }
        
    }
    
}


extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = ["Full name", "Hours"]
        return sections[section]
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = course.fullname
        } else {
            cell.textLabel?.text = course.hours
        }
        print(tableView.intrinsicContentSize)
        return cell
    }

}

extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        events.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "All" : Array(events.keys)[row - 1].id ?? ""
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSection = row == 0 ? nil : Array(events.keys)[row - 1]
        weekView.invalidate()
    }
    
    
}



extension Day {
    init(character: Character) {
        switch character {
        case "M":
            self = .Monday
        case "T":
            self = .Tuesday
        case "W":
            self = .Wednesday
        case "R":
            self = .Thursday
        case "F":
            self = .Friday
        default:
            self = .Monday
        }
    }
}

struct MeetingEvent: Event {
    var identifier: String
    var day: Day
    var start: Time
    var end: Time
}


class MeetingCell: UICollectionViewCell, MTSelfConfiguringEventCell {
    
    static var reuseId: String {
        return String(describing: self)
    }
    
    func configure(with data: Event) {
        if let meeting = data as? MeetingEvent {
            label.text = meeting.identifier
        }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
        contentView.layer.cornerRadius = 5
        contentView.layer.cornerCurve = .continuous
        contentView.backgroundColor = .systemTeal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITableView {
    
    override open var intrinsicContentSize: CGSize {
        contentSize
    }
    
}
//
extension UIPickerView {
    override open var intrinsicContentSize: CGSize {
        CGSize(width: frame.size.width, height: 75)
    }
}

extension Notification.Name {
    static let newTrackRequest = Notification.Name("new_track_request")
}
