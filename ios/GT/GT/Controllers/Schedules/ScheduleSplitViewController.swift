//
//  ScheduleSplitViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


class ScheduleSplitViewController: UISplitViewController {
    
    var schedulePicker: SideMenuTableViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        schedulePicker = (viewControllers.first as! UINavigationController).viewControllers.first as? SideMenuTableViewController
        schedulePicker.tableView.delegate = self
    }

}


extension ScheduleSplitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let courses = schedulePicker.schedules[indexPath.row].value
        let scheduleVC = ScheduleViewController()
        //scheduleVC.sectionPicker.courses = courses
        showDetailViewController(UINavigationController(rootViewController: scheduleVC), sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        500
    }
}
