//
//  DetailViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit
import MTWeekView
import Segmentio

class DetailViewController: UIViewController, MTWeekViewDataSource {
    
    var course: Course! {
        didSet {
            courseAttributes["Full Name"] = course.fullname
            courseAttributes["Hours"] = course.hours?.removeExtraSpaces()
            courseAttributes["Semester"] = course.semester
            courseAttributes["Grade Basis"] = course.gradeBasis
        }
    }

    var sections: Set<Section> {
        return (course.sections as? Set<Section>) ?? Set<Section>()
    }

    var currentSegment: SegmentioItem {
        return segmentioView.segmentioItems[segmentioView.selectedSegmentioIndex]
    }

    var tableView: CourseDetailTableView!
    var weekView: MTWeekView!

    var allEvents: [MeetingEvent]!

    var firstMeeting: Time = Time(hour: 8, minute: 0)
    var lastMeeting: Time = Time(hour: 20, minute: 0)
    var selectedSection: Section?
    var courseAttributes: [String: String?] = [:]

    var stack: UIStackView!
    var button: UIBarButtonItem!

    var segmentioView: Segmentio!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Track", style: .plain, target: self, action: #selector(trackButtonTapped))

        button = navigationItem.rightBarButtonItem!

        allEvents = Parser.parseEvents(course: course)

        tableView = CourseDetailTableView()
        tableView.attributes = courseAttributes
        
        weekView = MTWeekView()
        weekView.dataSource = self
        weekView.register(MeetingCell.self)
        weekView.setContentCompressionResistancePriority(UILayoutPriority(249), for: .vertical)
        
        view.backgroundColor = .systemBackground

       setupSegmentio()

        segmentioView.valueDidChange = { [weak self] segmentio, index in
            guard let self = self else { return }
            if index == 0 {
                self.weekView.showAll();
                self.button.title = "Track All Lectures"
                return

            }

            let segment = segmentio.segmentioItems[index]
            self.button.title = "Track \(segment.title ?? "")"
            self.weekView.showEvents { event in
                if let meeting = event as? MeetingEvent {
                    return meeting.name == segment.title
                }
                return false
            }

        }

        setupStack()
    }

    func setupStack() {
        stack = UIStackView(arrangedSubviews: [tableView, segmentioView, weekView])
        stack.axis = .vertical
        stack.setCustomSpacing(24, after: segmentioView)
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
        if segmentioView.selectedSegmentioIndex == 0 {
            NotificationCenter.default.post(name: .trackAllRequest, object: sections)
        } else {
            let section = sections.first { $0.id == currentSegment.title }
            NotificationCenter.default.post(name: .newTrackRequest, object: section)
        }
    }


    func allEvents(for weekView: MTWeekView) -> [Event] {
        allEvents
    }

    func segmentioContent() -> [SegmentioItem] {
        guard let sections = course.sections as? Set<Section> else { return [] }
        var content = sections.map { section -> SegmentioItem in
            var item = SegmentioItem(title: section.id, image: nil)
            if section.tracked {
                let seats = section.seats?.remaining ?? 0
                item.addBadge(Int(seats), color: .systemRed)
            }
            return item
        }.sorted { first, second in
            guard let t1 = first.title, let t2 = second.title else { return false }
            return t1.count < t2.count || t1 < t2
        }

        var all = SegmentioItem(title: "All", image: nil)
        content.insert(all, at: 0)
        return content
    }

    func setupSegmentio() {
        segmentioView = Segmentio()
        let options = SegmentioOptions(
            backgroundColor: .secondarySystemGroupedBackground,
            segmentPosition: .dynamic,
            scrollEnabled: true,
            labelTextAlignment: .center,
            segmentStates: SegmentioStates(
                defaultState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                    titleTextColor: .white
                ),
                selectedState: SegmentioState(
                    backgroundColor: .orange,
                    titleFont: UIFont.systemFont(ofSize: UIFont.systemFontSize),
                    titleTextColor: .black
                ),
                highlightedState: SegmentioState(
                    backgroundColor: UIColor.lightGray.withAlphaComponent(0.6),
                    titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                    titleTextColor: .black
                )
            )
        )


        segmentioView.setup(
            content: segmentioContent(),
            style: .onlyLabel,
            options: options
        )
        segmentioView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentioView.reloadSegmentio()
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



