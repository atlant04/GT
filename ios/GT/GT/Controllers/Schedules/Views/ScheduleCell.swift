//
//  ScheduleCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import MTWeekView



class ScheduleCell: UITableViewCell, ConfiguringCell, MTWeekViewDataSource {
    func allEvents(for weekView: MTWeekView) -> [Event] {
        (0...10).map { num in
            return MeetingEvent(day: Day.allCases.randomElement()!, start: Time(hour: num, minute: 0), end: Time(hour: num + 3, minute: 0))
        }
    }
    
    typealias Content = [String: [Course]]
    
    var schedule = [String: [Course]]() {
        didSet {
            weekView.reload()
        }
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    func configure(with content: [String: [Course]]) {
        schedule = content
    }
    
    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fall 2020"
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    let weekView: MTWeekView = {
        var config = LayoutConfiguration()
        config.hidesVerticalLines = true
        config.collisionStrategy = .combine
        config.headerHeight = 0
        config.timelineWidth = 0
        let weekView = MTWeekView(frame: .zero, configuration: config)
        weekView.translatesAutoresizingMaskIntoConstraints = false
        return weekView
    }()
    
    let courseList: CourseList = CourseList()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    var heightConstraint: NSLayoutConstraint?
    
    func commonInit() {
        guard let courseListView = courseList.collectionView else { return }
        weekView.dataSource = self
        weekView.register(MeetingCell.self)
        
        let stack = UIStackView(arrangedSubviews: [label, courseListView, weekView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)
        contentView.fill(with: stack, insets: .init(top: 0, left: 8, bottom: 0, right: 8))
        heightConstraint = courseListView.heightAnchor.constraint(equalToConstant: 0)
    
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
