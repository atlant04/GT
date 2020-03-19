//
//  DetailCourseViewController.swift
//  GT
//
//  Created by MacBook on 3/17/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit
import JZCalendarWeekView

class DetailCourseViewController: UIViewController {
    var calendar: CalendarView!
    var course: Course!

    override func viewDidLoad() {
        super.viewDidLoad()
        //calendar = CalendarView(frame: view.bounds)
        //view.addSubview(calendar)
        setupCalendar()
    }

    func setupCalendar() {

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendar)
    }


}

class CalendarView: JZBaseWeekView {
    override func registerViewClasses() {
        super.registerViewClasses()
        //self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: EventCell.reuseIdentifier)
        self.collectionView.register(EventCell.self, forCellWithReuseIdentifier: EventCell.reuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.reuseIdentifier, for: indexPath) as! EventCell
        let event = getCurrentEvent(with: indexPath) as! Event
        cell.update(event: event)
        return cell
    }
}


class Event: JZBaseEvent {
    override init(id: String, startDate: Date, endDate: Date) {
        super.init(id: "Text", startDate: startDate, endDate: endDate)
    }

    override func copy(with zone: NSZone?) -> Any {
        return Event(id: id, startDate: startDate, endDate: endDate)
    }
}


class EventCell: UICollectionViewCell {
    static let reuseIdentifier: String = "eventCell"

    func update(event: Event) {
        label.text = event.id
    }

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Test"
        return label
    }()

    let border: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        contentView.addSubview(label)
        contentView.addSubview(border)
        setupBasic()
        NSLayoutConstraint.activate([
            border.widthAnchor.constraint(equalToConstant: 2),
            border.topAnchor.constraint(equalTo: contentView.topAnchor),
            border.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: border.trailingAnchor, constant: 5),
            label.heightAnchor.constraint(equalToConstant: 15)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Plz stop using storyboards")
    }

    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.backgroundColor = UIColor(red: 238/255, green: 247/255, blue: 1, alpha: 1) //238, 247, 255
    }
}
