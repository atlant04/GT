////
////  DetailViewController.swift
////  GT
////
////  Created by Maksim Tochilkin on 23.03.2020.
////  Copyright © 2020 MT. All rights reserved.
////
//
//import UIKit
//import MTWeekView
//import Segmentio
//
//class DetailViewController: UIViewController, MTWeekViewDataSource {
//    
//    var course: Course! {
//        didSet {
//            courseAttributes["Full Name"] = course.fullname
//            courseAttributes["Hours"] = course.shours.removeExtraSpaces()
//            courseAttributes["Semester"] = course.semester.rawValue
//            courseAttributes["Grade Basis"] = course.gradeBasis
//        }
//    }
//
//    var sections: Set<Section> {
//        return (course.sections as? Set<Section>) ?? Set<Section>()
//    }
//
//    var currentSegment: SegmentioItem {
//        return segmentioView.segmentioItems[max(segmentioView.selectedSegmentioIndex, 0)]
//    }
//
//    var tableView: CourseDetailTableView!
//    var weekView: MTWeekView!
//
//    var allEvents: [MeetingEvent]!
//
//    var firstMeeting: Time = Time(hour: 8, minute: 0)
//    var lastMeeting: Time = Time(hour: 20, minute: 0)
//    var selectedSection: Section?
//    var courseAttributes: [String: String?] = [:]
//
//    var stack: UIStackView!
//    var button: UIBarButtonItem!
//
//    var segmentioView: Segmentio!
//
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.title = course.identifier
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Track", style: .plain, target: self, action: #selector(trackButtonTapped))
//
//        button = navigationItem.rightBarButtonItem!
//        extendedLayoutIncludesOpaqueBars = true
//        allEvents = course.events
//
//        tableView = CourseDetailTableView()
//        tableView.attributes = courseAttributes
//        
//        var config = LayoutConfiguration()
//        config.hidesVerticalLines = true
//        weekView = MTWeekView(frame: .zero, configuration: config)
//        weekView.register(MeetingCell.self)
//        weekView.dataSource = self
//        
//        view.backgroundColor = .systemBackground
//
//       setupSegmentio()
//
//        segmentioView.valueDidChange = { [weak self] segmentio, index in
//            guard let self = self else { return }
//            if index == 0 {
//                self.weekView.showAll();
//                self.button.title = "Track All Lectures"
//                return
//
//            }
//
//            let segment = segmentio.segmentioItems[index]
//            self.button.title = "Track \(segment.title ?? "")"
//            self.weekView.showEvents { event in
//                if let meeting = event as? MeetingEvent {
//                    return meeting.name == segment.title
//                }
//                return false
//            }
//
//        }
//
//        setupStack()
//    }
//    
//
//
//    func setupStack() {
//        stack = UIStackView(arrangedSubviews: [tableView, segmentioView, weekView])
//        stack.axis = .vertical
//        stack.distribution = .fill
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(stack)
//        stack.setCustomSpacing(8, after: segmentioView)
//        weekView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
//
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//    
//    @objc func trackButtonTapped() {
//        if segmentioView.selectedSegmentioIndex == 0 {
//            NotificationCenter.default.post(name: .trackAllRequest, object: sections)
//        } else {
//            let section = sections.first { $0.id == currentSegment.title }
//            NotificationCenter.default.post(name: .newTrackRequest, object: section)
//        }
//    }
//
//
//    func allEvents(for weekView: MTWeekView) -> [Event] {
//        allEvents
//    }
//
//    func segmentioContent() -> [SegmentioItem] {
//        guard let sections = course.sections as? Set<Section> else { return [] }
//        var content = sections.map { section -> SegmentioItem in
//            var item = SegmentioItem(title: section.id, image: nil)
////            if section.tracked {
////                let seats = section.seats?.remaining ?? 0
////                item.addBadge(Int(seats), color: .systemRed)
////            }
//            return item
//        }.sorted { first, second in
//            guard let t1 = first.title, let t2 = second.title else { return false }
//            return t1.count < t2.count || t1 < t2
//        }
//
//        let all = SegmentioItem(title: "All", image: nil)
//        content.insert(all, at: 0)
//        return content
//    }
//
//    func setupSegmentio() {
//        segmentioView = Segmentio()
//        let options = SegmentioOptions(
//            backgroundColor: .secondarySystemGroupedBackground,
//            segmentPosition: .dynamic,
//            scrollEnabled: true,
//            labelTextAlignment: .center,
//            segmentStates: SegmentioStates(
//                defaultState: SegmentioState(
//                    backgroundColor: .secondarySystemGroupedBackground,
//                    titleFont: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
//                    titleTextColor: traitCollection.userInterfaceStyle == .light ? .black : .white
//                ),
//                selectedState: SegmentioState(
//                    backgroundColor: .orange,
//                    titleFont: UIFont.systemFont(ofSize: UIFont.systemFontSize),
//                    titleTextColor: traitCollection.userInterfaceStyle == .light ? .black : .white
//                ),
//                highlightedState: SegmentioState(
//                    backgroundColor: UIColor.systemBackground.withAlphaComponent(0.6),
//                    titleFont: UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
//                    titleTextColor: traitCollection.userInterfaceStyle == .light ? .black : .white
//                )
//            )
//        )
//
//
//        segmentioView.setup(
//            content: segmentioContent(),
//            style: .onlyLabel,
//            options: options
//        )
//        segmentioView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        segmentioView.reloadSegmentio()
//    }
//    
//}
//
//

//
//
//public class MeetingObject: NSObject {
//    
////    public func encode(with coder: NSCoder) {
////        coder.encode(type, forKey: "type")
////        coder.encode(name, forKey: "name")
//////        coder.encode(day, forKey: "day")
//////        coder.encode(start, forKey: "start")
//////        coder.encode(end, forKey: "end")
////    }
//    
////    public required init?(coder: NSCoder) {
////        self.type = coder.decodeObject(forKey: "type") as? String
////        self.name = coder.decodeObject(forKey: "name") as? String
//////        self.day = coder.decodeObject(forKey: "day") as? Day ?? .Monday
//////        self.start = coder.decodeObject(forKey: "start") as? Time ?? Time(hour: 12, minute: 0)
//////        self.end = coder.decodeObject(forKey: "end") as? Time ?? Time(hour: 14, minute: 0)
////
////        self.day = .Monday
////        self.start = Time(hour: 12, minute: 0)
////        self.end = Time(hour: 14, minute: 0)
////    }
//    
//    public var type: String?
//    public var name: String?
//    public var day: Day
//    public var start: Time
//    public var end: Time
//
//    public static var supportsSecureCoding: Bool = true
//    
//    init(event: MeetingEvent) {
//        self.day = event.day
//        self.start = event.start
//        self.end = event.end
//        self.type = event.type
//        self.name = event.name
//        super.init()
//
//        self.event = event
//    }
//    
//    public var event: MeetingEvent {
//        get {
//            MeetingEvent(day: day, start: start, end: end)
//        }
//        
//        set {
//            self.day = newValue.day
//            self.start = newValue.start
//            self.end = newValue.end
//            self.type = newValue.type
//            self.name = newValue.name
//        }
//    }
//}
