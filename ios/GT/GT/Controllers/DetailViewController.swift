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
    var meetings: [Event]?
    var firstMeeting: Time = Time(hour: 8, minute: 0)
    var lastMeeting: Time = Time(hour: 20, minute: 0)
    
    var pickerView = UIPickerView()
    var weekViewHeightConstraint: NSLayoutConstraint!
    var isExpanded = false
    var sectionsTitles = [String]()
    var selectedSection: Section?
    var stack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = course.identifier
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Track", style: .done, target: self, action: #selector(trackButtonPressed))
        parseEvents()
    
        sectionsTitles = course.sections.compactMap { $0.id }.sorted()
        sectionsTitles.insert("All", at: 0)
        selectedSection = course.sections.first
        
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
        
        //weekViewHeightConstraint = weekView.heightAnchor.constraint(equalToConstant: 400)
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        
//        NSLayoutConstraint.activate([
//            weekView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            weekViewHeightConstraint,
//            weekView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 12),
//            weekView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.heightAnchor.constraint(equalToConstant: 400)
//        ])
        
        weekView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(expandWeekView(_:))))
        
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
    
    @objc func expandWeekView(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:{
                self.weekView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.weekView.alpha = 0.5
            })
        } else if recognizer.state == .ended {
            weekViewHeightConstraint.constant = isExpanded ? 400 : 800
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:{
                self.weekView.transform = .identity
                self.view.layoutIfNeeded()
                self.weekView.alpha = 1
            }) { _ in
                self.isExpanded = !self.isExpanded
            }
            
        }
    }
    
    @objc func trackButtonPressed() {
        let info = ["track": [course.identifier: selectedSection]]
        NotificationCenter.default.post(name: .track, object: self, userInfo: info)
    }
    
    func weekView(_ weekView: MTWeekView, eventsForDay day: Day) -> [Event] {
        //        if let meetings = self.meetings {
        //            let meetings = meetings.filter { $0.day == day }
        //            return meetings
        //        }
        //        return []
        return meetings?.filter { $0.day == day } ?? []
    }
    
    func hourRangeForWeek(_ weekView: MTWeekView) -> (start: Time, end: Time) {
        //        let sortedEvents = meetings?.sorted { $0.start.hour < $1.start.hour }
        //        if let first = sortedEvents?.first?.start, let last = sortedEvents?.last?.end {
        //            return (start: first, end: last + Time(hour: 1, minute: 0))
        //        }
//        let sortedEvents = meetings?.sorted { $0.start.hour < $1.start.hour }
//        if let first = sortedEvents?.first?.start, let last = sortedEvents?.last?.end {
//            return (start: first, end: last + Time(hour: 1, minute: 0))
//        }
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
    
    func parseEvents() {
        let meetings = course.sections.compactMap { $0.meetings }.joined()
        self.meetings = meetings.flatMap(parseMeeting)
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
        if indexPath.section == 2 {
            cell.contentView.addSubview(pickerView)
            cell.contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pickerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                pickerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                pickerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                pickerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                cell.contentView.heightAnchor.constraint(equalToConstant: 100)
            ])
        } else if indexPath.section == 0 {
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
        sectionsTitles.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        sectionsTitles[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            selectedSection = nil
            parseEvents()
            weekView.invalidate()
            return
        }
        selectedSection = course.sections[row - 1]
        meetings = selectedSection?.meetings.flatMap(parseMeeting)
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
        backgroundColor = .systemBlue
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

