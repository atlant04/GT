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

class ScheduleViewController: UIViewController, MTWeekViewDataSource {
    typealias SectionRow = Row<String, Section>
    
    var dataSource: UITableViewDiffableDataSource<String, Section>!
    var weekView: MTWeekView!
    var sectionPicker: SectionPickerTableView = SectionPickerTableView()
    var courses: [Course]? {
        didSet {
            if let courses = courses {
                rows = convertCoursesToRows(courses: courses)
                dataSource.applyRows(rows)
            }
        }
    }
    var rows: [SectionRow] = []
    var selectedRows: [SectionRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "My Schedule"
        view.backgroundColor = .black
        setupWeekView()
        
        view.addSubview(sectionPicker)
        NSLayoutConstraint.activate([
            sectionPicker.topAnchor.constraint(equalTo: weekView.bottomAnchor),
            sectionPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sectionPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sectionPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
    }
    
    func convertCoursesToRows(courses: [Course]) -> [SectionRow] {
        courses.compactMap { course -> [SectionRow] in
            (course.sections as! Set<Section>).map { SectionRow(section: course.identifier ?? "None", item: $0 )}
        }.reduce([], +)
    }
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<String, Section>(tableView: sectionPicker, cellProvider: { (tableView, indexPath, section) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: SectionPickerCell.reuseId, for: indexPath) as! SectionPickerCell
            cell.configure(section: self.rows[indexPath.row].item)
            return cell
        })
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CoursePickerCell()
        let tap = PropertyTapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tap.localObject = section
        view.addGestureRecognizer(tap)
        view.course = courses?[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           50
    }
    
    @objc func headerTapped(_ recognizer: PropertyTapGestureRecognizer) {
        guard let section = recognizer.localObject as? Int else { return }
        courses?[section].isCollapsed.toggle()
        sectionPicker.reloadSections([section], with: .automatic)
    }
    
    func setupWeekView() {
        var config = LayoutConfiguration()
        config.hidesVerticalLines = true
        config.collisionStrategy = .combine
        weekView = MTWeekView(frame: .zero, configuration: config)
        view.addSubview(weekView)
        weekView.translatesAutoresizingMaskIntoConstraints = false
        weekView.register(MeetingCell.self)
        weekView.dataSource = self
        
        NSLayoutConstraint.activate([
            weekView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }

    func allEvents(for weekView: MTWeekView) -> [Event] {
        return rows.flatMap { row -> [MeetingEvent] in
            guard let meetings = row.item.meetings as? Set<Meeting> else { return [] }
            return meetings.flatMap(Parser.parseMeeting(meeting:))
        }
    }
    
}

struct Row<SectionType, ItemType> where SectionType: Hashable, ItemType: Hashable {
    var section: SectionType
    var item: ItemType
}

extension UITableViewDiffableDataSource {
    typealias DiffableRow = Row<SectionIdentifierType, ItemIdentifierType>
    typealias RowProvider = (UITableView, DiffableRow) -> UITableViewCell?

    
    func applyRows(_ rows: [DiffableRow]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        let sections = rows.map(\.section)
        snapshot.appendSections(sections)
        for row in rows {
            snapshot.appendItems([row.item], toSection: row.section)
        }
        self.apply(snapshot)
    }
}
