//
//  ScheduleCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import MTWeekView

extension Schedule {
    var coursesArr: [Course]? {
        if let courses = self.courses as? Set<Course> {
             return Array(courses)
        }
        return nil
    }
}

extension Course {
    var sectionsArr: [Section]? {
        if let sections = self.sections as? Set<Section> {
             return Array(sections)
        }
        return nil
    }
    
    var allEvents: [MeetingEvent]? {
        sectionsArr?.compactMap { $0.allEvents }.reduce([], +)
    }
}


class ScheduleCell: UITableViewCell, ConfiguringCell, MTWeekViewDataSource {
    func allEvents(for weekView: MTWeekView) -> [Event] {
        []//schedule?.coursesArr?.compactMap { $0.allEvents }.reduce([], +) ?? []
    }
    
    typealias Content = Schedule
    
    var inEditMode = false
    var isChosen: Bool = false {
        didSet {
            selectImage.isHighlighted = isChosen
        }
    }
    
    lazy var overlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        view.clipsToBounds = true
        view.addSubview(selectImage)
        selectImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            selectImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            selectImage.widthAnchor.constraint(equalToConstant: 32),
            selectImage.heightAnchor.constraint(equalToConstant: 32)
        ])
        return view
    }()
    
    static let unselectedCheckmark = UIImage(systemName: "checkmark.circle")
    static let selectedCheckmark = UIImage(systemName: "checkmark.circle.fill")
    
    lazy var selectImage = UIImageView(
        image: ScheduleCell.unselectedCheckmark,
        highlightedImage: ScheduleCell.selectedCheckmark
    )
    
    var schedule: Schedule? {
        didSet {
            weekView.reload()
            courseList.courses = schedule?.coursesArr ?? []
        }
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    func configure(with content: Schedule) {
        schedule = content
        label.text = content.name
        courseList.courses = schedule?.coursesArr ?? []
    }
    
    var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        weekView.isUserInteractionEnabled = false
        return weekView
    }()
    
    lazy var addCourseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        return button
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
    
    func setEditMode(_ isEditing: Bool) {
        inEditMode = isEditing
        if inEditMode {
            overlay.frame = bounds
            contentView.addSubview(overlay)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int.random(in: 0...100))) {
                self.wiggle()
            }
        } else {
            contentView.subviews.first { $0 == overlay }?.removeFromSuperview()
            layer.removeAnimation(forKey: "transform")
            layer.removeAnimation(forKey: "scale")
        }
    }
    
    var header: UIStackView!
    func commonInit() {
        weekView.dataSource = self
        weekView.register(MeetingCell.self)
        weekView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        courseList.setContentHuggingPriority(.init(1000), for: .vertical)
        
        header = UIStackView(arrangedSubviews: [label, addCourseButton])
        header.addArrangedSubview(label)
        header.addArrangedSubview(addCourseButton)
        header.axis = .horizontal
        label.setContentHuggingPriority(.init(0), for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [header, courseList, weekView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 8
        
        selectionStyle = .none
    
        contentView.addSubview(stack)
        contentView.fill(with: stack, insets: .init(top: 16, left: 16, bottom: 0, right: 16))
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
