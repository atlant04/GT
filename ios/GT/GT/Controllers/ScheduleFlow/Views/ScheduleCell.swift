//
//  ScheduleCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import MTWeekView
import MTFlexBox

class ScheduleCell: UITableViewCell, ConfiguringCell, MTWeekViewDataSource, UITextFieldDelegate {
    func allEvents(for weekView: MTWeekView) -> [Event] {
        if let schedule = schedule {
            return Parser.events(scheduleWithColor: schedule)
        }
        return []
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
            courseList.items = Array(schedule?.items ?? [])
            weekView.reload()
        }
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    func configure(with content: Schedule) {
        schedule = content
        name.text = content.name
    }
    
    lazy var name: UITextField = {
        let label = UITextField()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .left
        label.isUserInteractionEnabled = false
        label.layer.cornerRadius = 6
        label.adjustsFontSizeToFitWidth = true
        label.layer.cornerCurve = .continuous
        label.delegate = self
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
    
    lazy var addCourseButton: ResizableButton = {
        let image = UIImage(systemName: "plus")!
        let button = ResizableButton()
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = .all(6)
        button.contentHorizontalAlignment = .trailing
        button.setContentHuggingPriority(.init(1000), for: .horizontal)
        return button
    }()
    
    lazy var editTitleButton: ResizableButton = {
        let image = UIImage(systemName: "square.and.pencil")!
        let button = ResizableButton()
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = .all(6)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var inInternalEditMode = false
    
    @objc
    func editButtonTapped() {
        inInternalEditMode.toggle()
        courseList.inEditMode = inInternalEditMode
        if inInternalEditMode {
            name.isUserInteractionEnabled = true
            name.backgroundColor = .secondarySystemBackground
            for cell in courseList.visibleCells {
                cell.wiggle(radians: 4)
            }
        } else {
            unsetInternalEditMode()
        }
    }
    
    func unsetInternalEditMode() {
        name.isUserInteractionEnabled = false
        name.backgroundColor = .clear
        for cell in courseList.visibleCells {
            cell.layer.removeAllAnimations()
        }
    }
    
    func onTextFieldReturn(textField: UITextField) -> Bool {
        unsetInternalEditMode()
        schedule?.name = textField.text
        try? CoreDataStack.shared.container.viewContext.save()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onTextFieldReturn(textField: textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        onTextFieldReturn(textField: textField)
    }
    
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
            layer.removeAllAnimations()
        }
    }
    
    var header: UIStackView!
    func commonInit() {
        weekView.dataSource = self
        weekView.register(MeetingCell.self)
        weekView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        courseList.setContentHuggingPriority(.init(1000), for: .vertical)

        let buttonStack = MTFlexBox {
            addCourseButton
            editTitleButton
            Spacer()
        }
    
        header = UIStackView(arrangedSubviews: [name, buttonStack])
        name.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        header.distribution = .fillEqually
        name.setContentHuggingPriority(.init(0), for: .horizontal)
        
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
        
        courseList.onRemoveItem = { [weak self] item in
            self?.schedule?.items?.remove(item)
            self?.courseList.items = Array(self?.schedule?.items ?? [])
            self?.weekView.reload()
        }
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}


class ResizableButton: UIButton {
    var scaleImageView: UIImageView?
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        scaleImageView = UIImageView(image: image)
        scaleImageView?.contentMode = .scaleAspectFit
        addSubview(scaleImageView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scaleImageView?.frame = bounds.inset(by: imageEdgeInsets)
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        guard let size = scaleImageView?.bounds else { return super.intrinsicContentSize }
        let side = min(size.height, size.width)
        return CGSize(width: side, height: side)
    }
}
