//
//  MainSplitViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import CoreData


class MainSplitViewController: UISplitViewController {
    var schedulePicker: SideMenuTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.preferredDisplayMode = .allVisible
        self.preferredPrimaryColumnWidthFraction = 0.3
        self.maximumPrimaryColumnWidth = 700
        schedulePicker = SideMenuTableViewController()
        viewControllers = [UINavigationController(schedulePicker)]
        
    }
    
    func getTestCourses() -> [Course] {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.predicate = NSPredicate(format: "number = 1332 OR number = 1331")
        return try! CoreDataStack.shared.container.viewContext.fetch(request)
    }

}


extension MainSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension UINavigationController {
    convenience init(_ controller: UIViewController) {
        self.init(rootViewController: controller)
        self.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
    }
}

extension UITableViewCell {
    func wiggle(duration: Double = 0.25) {
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 0.95
        scale.fillMode = .forwards
        scale.isRemovedOnCompletion = false
        
        
        let transform = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        transform.duration = 0.5
        transform.values = [
            0,
            2.0.inRadians,
            0,
            -2.0.inRadians,
            0
        ]
        transform.keyTimes  = [0, 0.25, 0.5, 0.75, 1]
        transform.isAdditive = true
        transform.repeatCount = .greatestFiniteMagnitude

        self.layer.add(transform, forKey: "transform")
        self.layer.add(scale, forKey: "scale")
    }
}

private func degreesToRadians(_ x: CGFloat) -> CGFloat {
    return .pi * x / 180.0
}
