//
//  TableViewDropDown.swift
//  GT
//
//  Created by Maksim Tochilkin on 31.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

class DropDownTableView: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var onSelect: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .popover
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        let style: UIBlurEffect.Style = traitCollection.userInterfaceStyle == .light ? .systemThinMaterialLight : .systemThinMaterialDark
        tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame.size.width = 200
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        AppConstants.Term.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = AppConstants.Term.allCases[indexPath.row].rawValue
        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        onSelect?(AppConstants.Term.allCases[indexPath.row].rawValue)
    }
}
