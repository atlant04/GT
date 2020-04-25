//
//  SectionPickerTableView.swift
//  GT
//
//  Created by Maksim Tochilkin on 25.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


final class SectionPickerTableView: UITableViewController {
    
    var courses: [Course]? {
        didSet {
            guard let courses = courses else { return }
            for course in courses {
                guard let sections = course.sections as? Set<Section> else { continue }
                map[course] = Array(sections)
            }
            tableView.reloadData()
        }
    }
    var onSelection: ((Section, Bool) -> Void)?
    var map: [Course: [Section]] = [:]
    
    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(SectionPickerCell.self, forCellReuseIdentifier: SectionPickerCell.reuseId)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        map.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return map[section].key.numberOfCollapsableItems
    }
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionPickerCell.reuseId, for: indexPath) as! SectionPickerCell

        if let section = section(at: indexPath) {
            cell.configure(section: section)
        }
        return cell
     
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SectionPickerCell
        cell.isChosen.toggle()
        if let section = section(at: indexPath) {
            onSelection?(section, cell.isChosen)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CoursePickerCell()
        let tap = PropertyTapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tap.localObject = section
        view.addGestureRecognizer(tap)
        view.course = map[section].key
        return view
    }
    
    func section(at indexPath: IndexPath) -> Section? {
        return map[indexPath.section].value[indexPath.item]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    @objc func headerTapped(_ recognizer: PropertyTapGestureRecognizer) {
        guard let section = recognizer.localObject as? Int else { return }
        map[section].key.isCollapsed.toggle()
        tableView.reloadSections([section], with: .automatic)
    }
    
}


class PropertyTapGestureRecognizer: UITapGestureRecognizer {
    var localObject: Any?
}
