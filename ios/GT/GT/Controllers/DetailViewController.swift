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
    
    var course: Course! {
        didSet {
            courseAttributes["Full Name"] = course.fullname
            courseAttributes["Hours"] = course.hours?.removeExtraSpaces()
            courseAttributes["Semester"] = course.semester
            courseAttributes["Grade Basis"] = course.gradeBasis
        }
    }
    var tableView: UITableView!
    var weekView: MTWeekView!
    var lectures: [Section: [Event]] = [:]
    var others: [Section: [Event]] = [:]
    var allEvents: [Section: [Event]] {
        return lectures.merging(others) { first, second in first }
    }
    var firstMeeting: Time = Time(hour: 8, minute: 0)
    var lastMeeting: Time = Time(hour: 20, minute: 0)
    var selectedSection: Section?
    var courseAttributes: [String: String?] = [:]
    
    var pickerView = UIPickerView()
    var stack: UIStackView!
    var button: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Track", style: .plain, target: self, action: #selector(trackButtonTapped))
        button = navigationItem.rightBarButtonItem!
        parseEvents()
        
        weekView = MTWeekView(frame: view.bounds, configuration: LayoutConfiguration())
        weekView.translatesAutoresizingMaskIntoConstraints = false
        weekView.dataSource = self
        weekView.registerCell(of: MeetingCell.self)
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.contentSize = CGSize(width: view.bounds.width, height: 200)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension

        
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        stack = UIStackView(arrangedSubviews: [tableView, pickerView, weekView])
        stack.axis = .vertical
        stack.setCustomSpacing(24, after: pickerView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])
        
    }
    
    @objc func trackButtonTapped() {
        if button.title == "Track All" {
            NotificationCenter.default.post(name: .trackAllRequest, object: Array(lectures.keys))
        } else {
            NotificationCenter.default.post(name: .newTrackRequest, object: selectedSection)
        }
    }
    
    func parseEvents() {
        guard let sections = course.sections as? Set<Section> else { return }
        for section in sections {
            if let meetings = section.meetings as? Set<Meeting> {
                var events = meetings.flatMap(parseMeeting)
                
                if (events.contains { $0.type == "Lecture*" }) {
                    lectures[section] = events
                } else {
                    others[section] = events
                }
            }
        }
    }
    
    func weekView(_ weekView: MTWeekView, eventsForDay day: Day) -> [Event] {
        if let section = selectedSection, let events = self.allEvents[section] {
            return events.filter { $0.day == day }
        }
        return Array(allEvents.values.joined()).filter { $0.day == day }
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
        if let startDate = formatter.date(from: String(start)),
            let endDate = formatter.date(from: String(end)) {
            let startTime = Time(from: startDate)
            let endTime = Time(from: endDate)
            
            return days.map { MeetingEvent(type: meeting.type, name: meeting.section?.id, day: $0, start: startTime, end: endTime)}
        } else {
            return []
        }
        
    }
    
}


extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? courseAttributes.count : 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
//        view.frame.size = CGSize(width: 100, height: 200)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            UIView.animate(withDuration: 0.5) {
                self.pickerView.alpha = self.pickerView.alpha == 1 ? 0 : 1
                self.pickerView.isHidden = !self.pickerView.isHidden
            }
        }
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if indexPath.section == 1 {
            cell.textLabel?.text = "Sections"
        } else {
            let attributes = courseAttributes[indexPath.row]
            cell.textLabel?.text = attributes.key
            cell.detailTextLabel?.text = attributes.value
        }
        
        cell.contentView.backgroundColor = .secondarySystemGroupedBackground
        return cell
    }

}

extension DetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return lectures.count + 1
        } else {
            return others.count + 1
        }
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "All"
        }
        if component == 0 {
            let index = lectures.index(lectures.startIndex, offsetBy: row - 1)
            return lectures.keys[index].id
        } else {
            let index = others.index(others.startIndex, offsetBy: row - 1)
            return others.keys[index].id
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 0 {
            selectedSection = nil
            
            if component == 0 {
                self.button.title = "Track All"
            } else {
                self.button.title = "Select section"
            }
            
            weekView.invalidate()
            return
        }
        
        if component == 0 {
            let index = lectures.index(lectures.startIndex, offsetBy: row - 1)
            selectedSection = lectures.keys[index]
        } else {
            let index = others.index(others.startIndex, offsetBy: row - 1)
            selectedSection = others.keys[index]
        }
        self.button.title = "Track \(selectedSection?.id ?? "")"
        
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
    var type: String?
    var name: String?
    var day: Day
    var start: Time
    var end: Time
    
    mutating func setName(name: String?) {
        self.name = name
    }
}


class MeetingCell: UICollectionViewCell, MTSelfConfiguringEventCell {
    
    static var reuseId: String {
        return String(describing: self)
    }
    
    func configure(with data: Event) {
        if let meeting = data as? MeetingEvent {
            label.text = meeting.name
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
        contentView.layer.cornerRadius = 2
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

extension UIPickerView {
    override open var intrinsicContentSize: CGSize {
        CGSize(width: frame.size.width, height: 80)
    }
}

extension Notification.Name {
    static let newTrackRequest = Notification.Name("new_track_request")
    static let trackAllRequest = Notification.Name("track_all_request")
}

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}
