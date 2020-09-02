//
//  Store.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import Combine
let store = CourseStore()

struct FilterReducer {
    var filters: [String: String] = [:]
    
    @discardableResult
    func apply(to state: CourseStore) -> CourseStore {
        state.courses = state.courses.filter { course in
            return course.attributes == state.filters[1] || course.school == state.filters[0]
        }
        return state
    }
}

struct SearchReducer {
    var query: String
    
    @discardableResult
    func apply(to state: CourseStore) -> CourseStore {
        state.filteredCourses = state.courses.filter { course in
            return query.isEmpty || course.fullname.lowercased().contains(query.lowercased())
        }
        return state
    }
}

struct ScheduleAdder {
    var name: String
    
    @discardableResult
    func apply(to state: ScheduleStore) -> ScheduleStore {
        let schedule = Schedule(name: name, items: [])
        state.schedules.append(schedule)
        Storage.shared.add(schedule)
        return state
    }
}

struct ScheduleItemAdder {
    var item: ScheduleItem
    var schedule: Schedule
    
    @discardableResult
    func apply(to state: ScheduleStore) -> ScheduleStore {
        if let index = state.schedules.firstIndex(of: schedule) {
            state.schedules[index].items.append(item)
        }
        
        return state
    }
}

struct ScheduleDeleter {
    var schedule: Schedule
    
    @discardableResult
    func apply(to state: ScheduleStore) -> ScheduleStore {
        //delete schedule
        return state
    }
}

class ScheduleStore {
    @Fetched var schedules: [Schedule]
    var publisher: CurrentValueSubject<[Schedule], Never>
    
    enum Actions {
        case addSchedule(String)
        case delete(Schedule)
        case addItem(ScheduleItem, Schedule)
    }
    
    init() {
        publisher = CurrentValueSubject([])
        publisher.send(self.schedules)
    }
    
    func submit(_ action: Actions) {
        switch action {
        case .addSchedule(let string):
            let adder = ScheduleAdder(name: string)
            adder.apply(to: self)
        case .delete(let schedule):
            let remover = ScheduleDeleter(schedule: schedule)
            remover.apply(to: self)
        case .addItem(let item, let schedule):
            let itemAdder = ScheduleItemAdder(item: item, schedule: schedule)
            itemAdder.apply(to: self)
        default:
            break
        }
        
        publisher.send(self.schedules)
    }
}

class CourseStore {
    
    enum Actions {
        case addFilter(String, String)
        case filter
        case search(String)
    }
    
    @Fetched var courses: [Course]
    
    let scheduleStore = ScheduleStore()
    
    lazy var filteredCourses: [Course] = self.courses
    var filterReducer = FilterReducer()
    
    var publisher: CurrentValueSubject<[Course], Never>
    
    init() {
        publisher = CurrentValueSubject([])
        
        if self.courses.count == 0 {
            Storage.shared.downloadCourses { [unowned self] resultls in
                self.$courses = resultls
                self.publisher.send(self.courses)
            }
        }
        
        publisher.send(self.courses)
    }
    
    let filters = ["School", "Attributes"]
    
    func submit(_ action: Actions) {
        switch action {
        case .addFilter(let key, let val):
            filterReducer.filters[key] = val
        case .filter:
            filterReducer.apply(to: self)
        case .search(let string):
            let searchReducer = SearchReducer(query: string)
            searchReducer.apply(to: self)
        }
        
        let diffs = self.courses.difference(from: filteredCourses).inferringMoves()
        diffs.insertions
        
        publisher.send(self.filteredCourses)
    }
    
    
}
