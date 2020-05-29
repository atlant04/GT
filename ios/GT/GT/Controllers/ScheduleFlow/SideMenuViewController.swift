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
//    {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    var selectedSchedules: [IndexPath: Schedule] = [:]
    var inEditMode = false
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
    
    @objc
    func deleteSelected() {
        selectedSchedules.values.forEach {
            try? CoreDataStack.shared.delete($0)
        }
        schedules = (try? CoreDataStack.shared.fetch(type: Schedule.self)) ?? []
        tableView.deleteRows(at: Array(selectedSchedules.keys), with: .automatic)
        selectedSchedules = [:]
    }
    
    @objc func handleEdit() {
        inEditMode.toggle()
        navigationItem.leftBarButtonItem = inEditMode ? deleteBarButton : nil
        deleteBarButton?.isEnabled = false
        tableView.reloadData()
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
                    self.schedules.append(schedule)
                    print(schedule)
                    alertVC.dismiss(animated: true, completion: nil)
                                   self.tableView.reloadData()
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
            self.schedules[sender.tag].addToCourses(course)
            try? CoreDataStack.shared.container.viewContext.save()
            print(self.schedules[sender.tag])
            vc.dismiss(animated: true, completion: {
                let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? ScheduleCell
                cell?.schedule = self.schedules[sender.tag]
                cell?.courseList.reloadData()
            })
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
        let schedule = schedules[indexPath.row]
        cell.setEditMode(inEditMode)
    }
    
}
