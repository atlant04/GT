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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 8, dy: 8)
    }
    
    var heightConstraint: NSLayoutConstraint?
    
    func commonInit() {
        weekView.dataSource = self
        weekView.register(MeetingCell.self)
        weekView.setContentHuggingPriority(UILayoutPriority(0), for: .vertical)
        let stack = UIStackView(arrangedSubviews: [label, courseList, weekView])
        
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 8
        selectionStyle = .none
    
        contentView.addSubview(stack)
        contentView.fill(with: stack, insets: .all(24))
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 5
        contentView.layer.borderColor = UIColor.systemBlue.cgColor
        contentView.clipsToBounds = true
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
