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
    
    var weekView: MTWeekView!
    var sectionPicker: SectionPickerTableView = SectionPickerTableView()
    var selectedSections = Set<Section>()
    var contentView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "My Schedule"
        view.backgroundColor = .black
        setupWeekView()
        
        
        //addChild(sectionPicker)
        //sectionPicker.didMove(toParent: self)
        //view.addSubview(sectionPicker.tableView)
        
//        NSLayoutConstraint.activate([
//            sectionPicker.tableView.topAnchor.constraint(equalTo: weekView.bottomAnchor),
//            sectionPicker.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            sectionPicker.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            sectionPicker.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])

        
//        sectionPicker.onSelection = { [weak self] section, selected in
//            guard let self = self else { return }
//            if selected {
//                self.selectedSections.insert(section)
//            } else {
//                self.selectedSections.remove(section)
//            }
//            self.weekView.reload()
//        }
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
        return selectedSections.flatMap { section -> [MeetingEvent] in
            guard let meetings = section.meetings as? Set<Meeting> else { return [] }
            return meetings.flatMap(Parser.parseMeeting(meeting:))
        }
    }
    
}
