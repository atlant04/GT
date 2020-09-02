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

extension UIView {
    func wiggle(radians: CGFloat = 2.0) {
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 0.95
        scale.fillMode = .forwards
        scale.isRemovedOnCompletion = false
        
        
        let transform = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        transform.duration = 0.5
        transform.values = [
            0,
            radians.inRadians,
            0,
            -radians.inRadians,
            0
        ]
        transform.keyTimes  = [0, 0.25, 0.5, 0.75, 1]
        transform.isAdditive = true
        transform.repeatCount = .greatestFiniteMagnitude

        self.layer.add(transform, forKey: "transform")
        self.layer.add(scale, forKey: "scale")
    }
}

