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
        var item: ScheduleItem
        var sections: [Section] {
            item.course.sections?.sorted(by: \.id) ?? []
        }
        var isHidden = false
        var _selected: [Section: Bool] = [:]
        var selectedSections: [Section] {
            get {
                _selected.compactMap { tuple -> Section? in
                    if tuple.value {
                        return tuple.key
                    }
                    return nil
                }
            }
            
            set {
                _selected = Dictionary(uniqueKeysWithValues: newValue.map{ ($0, true) })
            }
        }
        
        mutating func setSelected(section: Section, _ isSelected: Bool) {
            _selected[section] = isSelected
        }
        
        func isSelected(_ section: Section) -> Bool {
            return _selected[section] ?? false
        }

    }
    
    var weekView: MTWeekView!
    var sectionPicker: SectionPickerTableView = SectionPickerTableView()
    var separator = Separator()
    var layout: Layout!
    var schedule: Schedule? {
        didSet {
            if let items = schedule?.items {
                courseSections = items.compactMap { item -> CourseSection? in
                    var courseSection = CourseSection(item: item)
                    courseSection.selectedSections = Array(item.selectedSections ?? [])
                    return courseSection
                }
            }
            navigationItem.title = schedule?.name ?? "My Schedule"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let items = schedule?.items {
            for item in items {
                item.selectedSections = Set(courseSections.first { $0.item === item }?.selectedSections ?? [])
            }
        }
        try? CoreDataStack.shared.container.viewContext.save()
    }

    var courseSections: [CourseSection] = []
    var pickerContainer: ContainverView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout = Layout(view: view)
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemBackground
        setupSeparator()
        setupWeekView()
        sectionPicker.dataSource = self
        sectionPicker.delegate = self
    
        pickerContainer = ContainverView(frame: .zero, view: sectionPicker)
        view.addSubview(pickerContainer)
        
    }
    
    func setupSeparator() {
        view.addSubview(separator)
        separator.longPress.addTarget(self, action: #selector(handleLongPress))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !layout.alreadyLayedOut {
            separator.frame = layout.separatorFrame
            pickerContainer.frame = layout.pickerFrame
            weekView.frame = layout.weekViewFrame
        }
    }

    
    @objc func handleLongPress() {
        beginTracking = true
    }
    
    var beginTracking = false
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            layout.setTranslation(location.y)
            separator.frame = layout.separatorFrame
            pickerContainer.frame = layout.pickerFrame
            weekView.frame = layout.weekViewFrame
        }
    }

    func section(at indexPath: IndexPath) -> Section {
        return courseSections[indexPath.section].sections[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CoursePickerCell()
        let tap = PropertyTapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tap.localObject = section
        view.addGestureRecognizer(tap)
        view.course = courseSections[section].item.course
        view.layer.borderColor = UIColor(hex: courseSections[section].item.color)?.cgColor
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SectionPickerCell,
            let section = cell.section else { return }
        cell.isChosen.toggle()
        self.courseSections[indexPath.section].setSelected(section: section, cell.isChosen)
        weekView.reload()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        courseSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let courseSection = courseSections[section]
        return courseSection.isHidden ? 0 : courseSection.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionPickerCell.reuseId, for: indexPath) as! SectionPickerCell
        let section = self.section(at: indexPath)
        cell.configure(section: section)
        cell.isChosen = courseSections[indexPath.section].isSelected(section)
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
        weekView.register(MeetingCell.self)
        weekView.dataSource = self
    }
    
    func allEvents(for weekView: MTWeekView) -> [Event] {
        var events = [MeetingEvent]()
        for c in courseSections {
            events += c.selectedSections.flatten { Parser.events(for: $0, withColor: c.item.color)}
        }
        return events
    }
    
}

class ContainverView: UIView {
    weak var enclosingView: UIView?
    
    convenience init(frame: CGRect, view: UIView) {
        self.init(frame: frame)
        enclosingView = view
        enclosingView?.translatesAutoresizingMaskIntoConstraints = false
        if let view = enclosingView {
            addSubview(view)
            self.fill(with: view)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct Layout {
    unowned var view: UIView
    var translation: CGFloat?
    
    var alreadyLayedOut: Bool {
        return translation != nil
    }
    
    var safeBounds: CGRect {
        view.bounds.inset(by: view.safeAreaInsets)
    }
    
    var separatorFrame: CGRect {
        let y: CGFloat = translation == nil ? safeBounds.midY : max(translation!, 200 + view.safeAreaInsets.top)
        return CGRect(x: 0, y: y, width: safeBounds.width, height: 20)
    }
    
    var pickerFrame: CGRect {
        CGRect(x: 0, y: separatorFrame.maxY, width: safeBounds.width, height: safeBounds.midY - separatorFrame.height)
    }
    
    var weekViewFrame: CGRect {
        CGRect(x: 0, y: safeBounds.minY, width: safeBounds.width, height: separatorFrame.minY - safeBounds.minY)
    }
    
    mutating func setTranslation(_ y: CGFloat) {
        self.translation = y
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
