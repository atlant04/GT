//
//  SideMenuViewController.swift
//  GT
//
//  Created by MacBook on 4/21/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import Combine

class SideMenuTableViewController: UITableViewController {

    var schedules: [Schedule] = store.scheduleStore.schedules
    
    var selectedSchedules: [IndexPath: Schedule] = [:]
    var inEditMode = false {
        didSet {
            navigationItem.leftBarButtonItem = inEditMode ? deleteBarButton : nil
            deleteBarButton?.isEnabled = false
            tableView.reloadData()
        }
    }
    var deleteBarButton: UIBarButtonItem?
    var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Schedules"
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 200
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddScheduleAlert)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEdit))
        ]
        deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelected))
        
        cancellable = store.scheduleStore.publisher.sink(receiveValue: { [unowned self] schedules in
            self.schedules = schedules
            self.tableView.reloadData()
        })
        
    }
    
    @objc
    func deleteSelected() {
        for schedule in self.selectedSchedules.values {
            store.scheduleStore.submit(.delete(schedule))
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
                store.scheduleStore.submit(.addSchedule(text))
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
        let courseAdder = CourseAdderTableViewController(schedule: schedules[sender.tag])
        self.present(UINavigationController(rootViewController: courseAdder), animated: true, completion: nil)
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
            self.navigationController?.pushViewController(scheduleVC, animated: true)
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

//#if DEBUG
//import SwiftUI
//import CoreData
//typealias VC = SideMenuTableViewController
//
//struct Preview: PreviewProvider {
//    static var previews: some View {
//        let vc = VC()
//        vc.schedules = try! CoreDataStack.shared.fetch(type: Schedule.self)
//        return vc.preview
//    }
//}
//#endif
