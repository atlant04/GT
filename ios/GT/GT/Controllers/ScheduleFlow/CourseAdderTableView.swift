//
//  CourseAdderTableView.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import Combine

final class CourseAdderTableView: UITableView, UITableViewDelegate {
    var searchPublisher: AnyPublisher<[Course], Never>? {
        didSet {
            bag = searchPublisher?.sink(receiveValue: self.reloadData(with:))
        }
    }
    var bag: AnyCancellable?
    
    var didSelectCourse: (Course) -> () = { _ in }

    lazy var source = UITableViewDiffableDataSource<String, Course>(tableView: self) { (table, index, course) -> UITableViewCell? in
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: index)
        cell.textLabel?.text = course.fullname
        cell.backgroundColor = .clear
        return cell
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)
        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.dataSource = source
        self.tableFooterView = UIView()
        self.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let course = source.itemIdentifier(for: indexPath) {
            didSelectCourse(course)
        }
    }
    
    func reloadData(with courses: [Course]) {
        var snap = NSDiffableDataSourceSnapshot<String, Course>()
        snap.appendSections(["Default"])
        snap.appendItems(courses)
        source.apply(snap, animatingDifferences: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
