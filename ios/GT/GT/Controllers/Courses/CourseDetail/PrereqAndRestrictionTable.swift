//
//  PrereqAndRestrictionTable.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

extension Prerequisite {
    func traversePrereqs(root: Prerequisite, into arr: inout [Prerequisite]) {
        arr.append(root)
        for additional in root.additional {
            traversePrereqs(root: additional, into: &arr)
        }
    }
    
    var traversed: [Prerequisite] {
        var arr = [Prerequisite]()
        traversePrereqs(root: self, into: &arr)
        return arr
    }
}

final class PrereqAndRestrictionTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    let course: Course
    var prereqs: [Prerequisite]
    
    var restrictions: [Restriction] {
        course.restrictions?.restrictions ?? []
    }
    
    
    init(course: Course) {
        self.course = course
        self.prereqs = course.prerequisites?.traversed ?? []
        super.init(frame: .zero, style: .insetGrouped)
        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.dataSource = self
        self.delegate = self
        self.alwaysBounceVertical = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "Prerequisites" : "Restrictions"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return prereqs.count
        } else if section == 1 {
            return restrictions.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = prereqs[indexPath.row].courses.joined(separator: ", ")
        } else {
            cell.textLabel?.text = restrictions[indexPath.row].requirements.joined(separator: ", ")
        }
        
        return cell
    }
    
}
