//
//  SideMenuViewController.swift
//  GT
//
//  Created by MacBook on 4/21/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

class SideMenuTableViewController: UITableViewController {

    var schedules: [String: [Course]] = [:]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = "Schedules"
        
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddScheduleAlert))
    }

    @objc func presentAddScheduleAlert() {
        let alertVC = UIAlertController(title: "New Schedule", message: "Enter Schedule Name", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let textField = alertVC.textFields?.first!
            if let text = textField?.text, !text.isEmpty {
                self.schedules[text] = []
                alertVC.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
        }
        alertVC.addTextField(configurationHandler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseIdentifier, for: indexPath) as! ScheduleCell
    
        var transform = CGAffineTransform(rotationAngle: CGFloat.pi / 40)
        transform.a = 1
        transform.d = 1
        cell.layer.anchorPoint = .init(x: 0.5, y: 0.5)
        //cell.transform = transform
        
        //cell.layer.mask = maskLayer
//        let scheduleName = Array(schedules.keys)[indexPath.row]
//        cell.textLabel?.text = scheduleName
//        let button = PropertyButton(type: .contactAdd)
//        button.localObject = scheduleName
//        button.addTarget(self, action: #selector(presentSearchVC(_:)), for: .touchUpInside)
//        cell.accessoryView = button
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cell = tableView.cellForRow(at: .init(row: 0, section: 0)) as! ScheduleCell
        print(cell.courseList.intrinsicContentSize)
        print(cell.weekView.intrinsicContentSize)
        print(cell.label.intrinsicContentSize)
    }

    @objc func presentSearchVC(_ sender: UIButton) {
        guard let button = sender as? PropertyButton,
            let schedule = button.localObject as? String else { return }

        let searchVC = SearchViewController()
        searchVC.onSelected = { [weak self] course, vc in
            guard let self = self else { return }
            self.schedules[schedule]?.append(course)
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(UINavigationController(rootViewController: searchVC), animated: true, completion: nil)
    }
}


class PropertyButton: UIButton {
    var localObject: Any?
}

