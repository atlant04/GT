//
//  Extensions.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit
import MTWeekView

protocol Collapsable {
    var isCollapsed: Bool { get set }
    var numberOfCollapsableItems: Int { get }
}

extension Course: Collapsable {
    private static var collapsables = [String: Bool]()
    
    var isCollapsed: Bool {
        get {
            guard let name = name else { return false}
            return Course.collapsables[name] ?? false
        }
        set {
            guard let name = name else { return }
            Course.collapsables[name] = newValue
        }
    }
    
    var numberOfCollapsableItems: Int {
        return isCollapsed ? 0 : sections?.count ?? 0
    }
    
}

extension Bool {
    mutating func toggle() {
        self = !self
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as! T
    }
}


extension Notification.Name {
    static let newTrackRequest = Notification.Name("new_track_request")
    static let trackAllRequest = Notification.Name("track_all_request")
}

extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}

extension Day {
    init(character: Character) {
        switch character {
        case "M":
            self = .Monday
        case "T":
            self = .Tuesday
        case "W":
            self = .Wednesday
        case "R":
            self = .Thursday
        case "F":
            self = .Friday
        default:
            self = .Monday
        }
    }
}

extension UIEdgeInsets {
    static var all: (CGFloat) -> UIEdgeInsets = { inset in
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
}

extension UIView {
    func fill(with view: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right),
        ])
    }

    func center(in view: UIView) {
        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

extension Array {
    func keyMap<Key: Hashable>(with key: (Element) -> Key) -> [Key: [Element]] {
        var dict = [Key: [Element]]()
        for element in self {
            dict[key(element)]?.append(element)
        }
        return dict
    }
}

extension CaseIterable {
    static func getCases() -> [Self.AllCases.Element] {
        var array = [Self.AllCases.Element]()
        for element in Self.allCases {
            array.append(element)
        }
        return array
    }
}

extension Date {

  static func today() -> Date {
      return Date()
  }

  func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.next,
               weekday,
               considerToday: considerToday)
  }

  func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
    return get(.previous,
               weekday,
               considerToday: considerToday)
  }

  func get(_ direction: SearchDirection,
           _ weekDay: Weekday,
           considerToday consider: Bool = false) -> Date {

    let dayName = weekDay.rawValue

    let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }

    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

    let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1

    let calendar = Calendar(identifier: .gregorian)

    if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
      return self
    }

    var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
    nextDateComponent.weekday = searchWeekdayIndex

    let date = calendar.nextDate(after: self,
                                 matching: nextDateComponent,
                                 matchingPolicy: .nextTime,
                                 direction: direction.calendarSearchDirection)

    return date!
  }

}

// MARK: Helper methods
extension Date {
  func getWeekDaysInEnglish() -> [String] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar.weekdaySymbols
  }

  enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
  }

  enum SearchDirection {
    case next
    case previous

    var calendarSearchDirection: Calendar.SearchDirection {
      switch self {
      case .next:
        return .forward
      case .previous:
        return .backward
      }
    }
  }
}


extension Date {
    static func getCurrentWeek() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        return (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }
            .filter { !calendar.isDateInWeekend($0) }
    }
}

extension CaseIterable where Self: Equatable {

    public func ordinal() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }

}

extension String {

    func removeExtraSpaces() -> String {
        return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    }

}

extension FloatingPoint {
    var inRadians: Self {
        return Self.pi * self / 180
    }
}
