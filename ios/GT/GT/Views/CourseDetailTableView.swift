//
//  CourseDetailTableView.swift
//  GT
//
//  Created by MacBook on 4/17/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


class CourseDetailTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var attributes: [String: String?]! {
        didSet { reloadData() }
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .insetGrouped)
        commonInit()
    }

    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
        separatorStyle = .none
        estimatedRowHeight = 50
        rowHeight = UITableView.automaticDimension
        delegate = self
        dataSource = self

        register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override open var intrinsicContentSize: CGSize {
        return contentSize
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attributes.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")

        let attribute = attributes[indexPath.row]
        cell.textLabel?.text = attribute.key
        cell.detailTextLabel?.text = attribute.value

        cell.contentView.backgroundColor = .secondarySystemGroupedBackground
        return cell
    }

}


