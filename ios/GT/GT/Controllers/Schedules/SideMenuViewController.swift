//
//  SideMenuViewController.swift
//  GT
//
//  Created by MacBook on 4/21/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuTableViewController: UITableViewController {

    //@AutoUserDefaults<[String: [Course]]>(key: "schedules", defaultValue: [:])
    var schedules: [String: [Course]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Schedules"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "schedule_cell")
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddScheduleAlert))
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
        schedules.keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schedule_cell", for: indexPath)
        let scheduleName = Array(schedules.keys)[indexPath.row]
        cell.textLabel?.text = scheduleName
        let button = PropertyButton(type: .contactAdd)
        button.localObject = scheduleName
        button.addTarget(self, action: #selector(presentSearchVC(_:)), for: .touchUpInside)
        cell.accessoryView = button
        return cell
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
