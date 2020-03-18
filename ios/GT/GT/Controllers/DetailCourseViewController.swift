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

class DetailCourseViewController: UIViewController, JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
    }


    var calendar: JZBaseWeekView!
    let baseDate: Date = Date()
    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar = JZBaseWeekView(frame: view.bounds)

        for i in 1...10 {
            let event = Event(id: "Test", startDate: baseDate, endDate: Date(timeInterval: TimeInterval(3600 * 10), since: baseDate))
            events.append(event)
        }
        print(baseDate.description)
        print(Date(timeInterval: TimeInterval(3600 * 10), since: baseDate).description)
        let mappedEvents = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
        calendar.baseDelegate = self
        calendar.setupCalendar(numOfDays: 7, setDate: baseDate, allEvents: [baseDate: [Event(id: "Test", startDate: baseDate, endDate: baseDate.addingTimeInterval(36000))]])

        view.addSubview(calendar)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendar)
    }


}

class CalendarView: JZBaseWeekView {
    override func registerViewClasses() {
        super.registerViewClasses()
        self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: EventCell.reuseIdentifier)
        //self.collectionView.register(EventCell.self, forCellWithReuseIdentifier: EventCell.reuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.reuseIdentifier, for: indexPath) as! EventCell
        cell.update(event: allEventsBySection[date]![indexPath.row] as! Event)
        return cell
    }
}


class Event: JZBaseEvent {
    override init(id: String, startDate: Date, endDate: Date) {
        super.init(id: "Text", startDate: startDate, endDate: endDate)
    }
}


class EventCell: UICollectionViewCell {
    static let reuseIdentifier: String = "eventCell"

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var border: UIView!

    func update(event: Event) {
        title.text = event.id
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupBasic()
    }

    func setupBasic() {
        self.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0
        title.font = UIFont.systemFont(ofSize: 12)
        title.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.backgroundColor = .systemBlue
        border.backgroundColor = .systemRed
    }

//    let label: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.backgroundColor = .black
//        label.text = "Test"
//        return label
//    }()


//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .systemBlue
//        contentView.addSubview(label)
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            label.heightAnchor.constraint(equalToConstant: 15)
//        ])
//    }

    required init?(coder: NSCoder) {
        fatalError("Plz stop using storyboards")
    }
}
