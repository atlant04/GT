//
//  ScheduleViewController.swift
//  GT
//
//  Created by MacBook on 4/21/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import SideMenu
import MTWeekView

class ScheduleViewController: UIViewController, MTWeekViewDataSource, SideMenuNavigationControllerDelegate {
    var menu: SideMenuNavigationController!
    let weekView = MTWeekView()
    var selectedCourses: [Course]? {
        didSet {
            weekView.reload()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "My Schedule"
        var config = LayoutConfiguration()
        config.hidesVerticalLines = true
        weekView.configuration = config
        view.addSubview(weekView)
        weekView.translatesAutoresizingMaskIntoConstraints = false
        weekView.register(MeetingCell.self)
        view.fill(with: weekView)
        weekView.dataSource = self

        let main = UIStoryboard(name: "Main", bundle: .main)
        menu = main.instantiateViewController(identifier: "leftMenu")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "square.grid.2x2"), style: .plain, target: self, action: #selector(presentMenu(_:)))

        (menu.viewControllers.first as? SideMenuTableViewController)?.onDoneBlock = { name, courses in
            self.navigationItem.title = name
            self.selectedCourses = courses
        }


        menu.statusBarEndAlpha = 0
        menu.animationOptions = .curveEaseInOut
        menu.presentationStyle = presentStyle()
        menu.menuWidth = view.bounds.width * 2 / 3
        menu.blurEffectStyle = traitCollection.userInterfaceStyle == .light ? .light : .dark
    }



    func presentStyle() -> SideMenuPresentationStyle {
        let style: SideMenuPresentationStyle = .viewSlideOutMenuIn
        style.menuStartAlpha = 0.5
        style.menuScaleFactor = 1.5
        style.onTopShadowOpacity = 0.8
        style.presentingEndAlpha = 0.3
        style.presentingScaleFactor = 0.9
        style.presentingTranslateFactor = 1
        return style
    }
    
    @objc func presentMenu(_ sender: UIBarButtonItem) {
        self.present(menu, animated: true) {
            print("sppearing")
        }
    }

    func allEvents(for weekView: MTWeekView) -> [Event] {
        guard let selectedCourses = selectedCourses else { return [] }
        return selectedCourses.flatMap { course in
            Parser.parseEvents(course: course)
        }
    }

    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        weekView.reload()
    }

}

