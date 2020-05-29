//
//  ScheduleViewController.swift
//  GT
//
//  Created by MacBook on 4/21/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import MTWeekView
import CoreData

class ScheduleViewController: UIViewController, MTWeekViewDataSource, UITableViewDataSource, UITableViewDelegate {

    struct CourseSection {
        var course: Course
        var sections: [Section]
        var isHidden = false
        var _selected: [Section: Bool] = [:]
        var selectedSections: [Section] {
            _selected.compactMap { tuple -> Section? in
                if tuple.value {
                    return tuple.key
                }
                return nil
            }
        }
        
        mutating func select(_ section: Section) {
            _selected[section] = true
        }
        mutating func unselect(_ section: Section) {
            _selected[section] = false
        }

    }
    
    var weekView: MTWeekView!
    var sectionPicker: SectionPickerTableView = SectionPickerTableView()
    
    var schedule: Schedule? {
        didSet {
            if let courses = schedule?.coursesArr {
                courseSections = courses.compactMap { course -> CourseSection? in
                    if let sections = (course.sections as? Set<Section>)?.sorted(by: \.id) {
                        return CourseSection(course: course, sections: sections)
                    }
                    return nil
                }
            }
        }
    }

    var courseSections: [CourseSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "My Schedule"
        view.backgroundColor = .black
        setupWeekView()
        sectionPicker.dataSource = self
        sectionPicker.delegate = self
        
        
        view.addSubview(sectionPicker)
        NSLayoutConstraint.activate([
            sectionPicker.topAnchor.constraint(equalTo: weekView.bottomAnchor),
            sectionPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sectionPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sectionPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }

    func section(at indexPath: IndexPath) -> Section {
        return courseSections[indexPath.section].sections[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CoursePickerCell()
        let tap = PropertyTapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tap.localObject = section
        view.addGestureRecognizer(tap)
        view.course = courseSections[section].course
        return view
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SectionPickerCell,
            let section = cell.section else { return }
        cell.isChosen.toggle()
        if cell.isChosen {
            self.courseSections[indexPath.section].select(section)
        } else {
            self.courseSections[indexPath.section].unselect(section)
        }
        weekView.reload()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        schedule?.courses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let courseSection = courseSections[section]
        return courseSection.isHidden ? 0 : courseSection.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionPickerCell.reuseId, for: indexPath) as! SectionPickerCell
        let section = self.section(at: indexPath)
        cell.configure(section: section)
        cell.isChosen = courseSections[indexPath.section]._selected[section] ?? false
        return cell
    }
    
    
    @objc func headerTapped(_ recognizer: PropertyTapGestureRecognizer) {
        guard let section = recognizer.localObject as? Int else { return }
        self.courseSections[section].isHidden.toggle()
        
        if self.courseSections[section].isHidden {
            let paths = self.courseSections[section].sections.enumerate { IndexPath(row: $0, section: section) }
            sectionPicker.deleteRows(at: paths, with: .fade)
        } else {
            sectionPicker.reloadSections([section], with: .automatic)
        }
    }
    
    
    func setupWeekView() {
        var config = LayoutConfiguration()
        config.hidesVerticalLines = true
        config.collisionStrategy = .combine
        config.start = Time(hour: 8, minute: 0)
        config.end = Time(hour: 20, minute: 0)
        weekView = MTWeekView(frame: .zero, configuration: config)
        view.addSubview(weekView)
        weekView.translatesAutoresizingMaskIntoConstraints = false
        weekView.register(MeetingCell.self)
        weekView.dataSource = self
        
        NSLayoutConstraint.activate([
            weekView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }
    
    func allEvents(for weekView: MTWeekView) -> [Event] {
        return courseSections.flatMap { $0.selectedSections }.flatMap { section -> [MeetingEvent] in
            guard let meetings = section.meetings as? Set<Meeting> else { return [] }
            return meetings.compactMap { $0.all }.reduce([], +)
        }
    }
    
}

struct Row<SectionType, ItemType> where SectionType: Hashable, ItemType: Hashable {
    var section: SectionType
    var item: ItemType
}

class DataSource<Section, Item>: UITableViewDiffableDataSource<Section, Item> where Section: Hashable, Item: Hashable {
    typealias DiffableRow = Row<Section, Item>
    typealias RowProvider = (UITableView, DiffableRow) -> UITableViewCell?
    
    
    func applyRows(_ rows: [DiffableRow]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let sections = Set(rows.map(\.section))
        snapshot.appendSections(Array(sections))
        for row in rows {
            snapshot.appendItems([row.item], toSection: row.section)
        }
        self.apply(snapshot)
    }
    
}

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        return sorted { a, b in
            guard let first = a[keyPath: keyPath], let second = b[keyPath: keyPath] else { return false }
            return first < second
        }
    }
    
    func enumerate<T>(_ handler: (Int) -> T) -> [T] {
        var arr = [T]()
        for (index, element) in self.enumerated() {
            arr.append(handler(index))
        }
        return arr
    }
}
