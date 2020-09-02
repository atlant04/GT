//
//  FilterTableViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import RealmSwift

final class FilterTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    @IBAction func applyFilters(_ sender: UIButton) {
        store.submit(.filter)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        store.filters.count + 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < store.filters.count {
            return store.filters[section]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 2 ? UITableView.automaticDimension : 120
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "FilterButton", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterItemCell", for: indexPath) as! FilterItemCell
        switch indexPath.section {
        case 0:
            cell.configure(with: store.courses.unique(\.school).sorted())
        case 1:
            cell.configure(with: store.courses.unique(\.attributes).compactMap { $0 })
        default:
            break;
        }
        
        cell.tag = indexPath.section
        
        return cell
    }
}


extension Array {
    func unique<T: Hashable>(_ keyPath: KeyPath<Element, T>) -> [T] {
        var set = Set<T>()
        
        return self.compactMap { element in
            let item = element[keyPath: keyPath]
            return set.insert(item).inserted ? item : nil
        }
    }
}
