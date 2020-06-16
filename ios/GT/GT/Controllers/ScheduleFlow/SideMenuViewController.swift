//
//  SideMenuViewController.swift
//  GT
//
//  Created by MacBook on 4/21/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

class SideMenuTableViewController: UITableViewController {

    var schedules = [Schedule]()
    var selectedSchedules: [IndexPath: Schedule] = [:]
    var inEditMode = false {
        didSet {
            navigationItem.leftBarButtonItem = inEditMode ? deleteBarButton : nil
            deleteBarButton?.isEnabled = false
            tableView.reloadData()
        }
    }
    var deleteBarButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Schedules"
        schedules = (try? CoreDataStack.shared.fetch(type: Schedule.self)) ?? []
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddScheduleAlert)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEdit))
        ]
        deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelected))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(CoreDataStack.shared.save())
    }
    
    @objc
    func deleteSelected() {
        selectedSchedules.values.forEach {
            try? CoreDataStack.shared.delete($0)
        }
        schedules = (try? CoreDataStack.shared.fetch(type: Schedule.self)) ?? []
        tableView.deleteRows(at: Array(selectedSchedules.keys), with: .automatic)
        selectedSchedules = [:]
        if schedules.count < 1 {
            inEditMode.toggle()
        }
    }
    
    @objc func handleEdit() {
        inEditMode.toggle()
    }
    
    @objc func presentAddScheduleAlert() {
        let alertVC = UIAlertController(title: "New Schedule", message: "Enter Schedule Name", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let textField = alertVC.textFields?.first!
            if let text = textField?.text, !text.isEmpty {
                do {
                    let schedule = try CoreDataStack.shared.newObject(type: Schedule.self) { schedule in
                        schedule.name = text
                    }
                    if schedule != nil {
                        self.schedules.append(schedule!)
                        alertVC.dismiss(animated: true, completion: nil)
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
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
        schedules.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseIdentifier, for: indexPath) as! ScheduleCell
        cell.configure(with: schedules[indexPath.row])
        cell.addCourseButton.tag = indexPath.row
        cell.addCourseButton.addTarget(self, action: #selector(handleAddCourse(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc
    func handleAddCourse(_ sender: UIButton) {
        let searchVC = SearchViewController()
        searchVC.onSelected = { [weak self] course, vc in
            guard let self = self else { return }
            searchVC.dismiss(animated: true, completion: {
                let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? ScheduleCell
                cell?.schedule = self.schedules[sender.tag]
            })
            vc.dismiss(animated: true, completion: nil)
            let item = ScheduleItem(context: CoreDataStack.shared.container.viewContext)
            item.color = AppConstants.randomColors.randomElement()!.hexString
            item.course = course
            self.schedules[sender.tag].items?.insert(item)
        }
        self.present(UINavigationController(rootViewController: searchVC), animated: true, completion: nil)
    }

}

extension SideMenuTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ScheduleCell else { return }
        
        let schedule = schedules[indexPath.row]
        
        if inEditMode {
            if cell.isChosen {
                selectedSchedules.removeValue(forKey: indexPath)
            } else {
                selectedSchedules[indexPath] = schedule
            }
            cell.isChosen.toggle()
            deleteBarButton?.isEnabled = !selectedSchedules.isEmpty
        } else {
            let scheduleVC = ScheduleViewController()
            scheduleVC.schedule = schedule
            showDetailViewController(UINavigationController(rootViewController: scheduleVC), sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ScheduleCell else { return }
        cell.setEditMode(inEditMode)
    }
    
}
