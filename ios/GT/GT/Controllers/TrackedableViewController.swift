//
//  TrackedableViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 24.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import ObjectMapper

class TrackedableViewController: UITableViewController {

    var sections = Set<Course.Section>()
    var results = [Pair<Course.Section, MTResponse>]()
    let response = MTResponse(JSON: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UserDefaults.standard.object(forKey: "sections") as? String,
            let sections = Mapper<Course.Section>().mapArray(JSONString: data) {
            self.sections = Set<Course.Section>(sections)
            update()
        }
        tableView.register(SectionCell.self, forCellReuseIdentifier: SectionCell.reuseId)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTrackingRequest(_:)), name: .track, object: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func didReceiveTrackingRequest(_ notification: Notification) {
        print(notification.userInfo?["track"])
        if let dict = notification.userInfo?["track"] as? [String: Course.Section] {
            if var section = dict.values.first {
                section.parentId = dict.keys.first
                let inserted = sections.insert(section).inserted
                if inserted {
                    fetch(section: section)
                }
            }
        }
    }
    
    deinit {
        let jsonData = sections.toJSONString()
        UserDefaults.standard.setValue(jsonData, forKey: "sections")
    }
    
    func update() {
        results = []
        for section in self.sections {
            fetch(section: section)
        }
    }
    
    func fetch(section: Course.Section) {
        ServerManager.shared.listen(to: section) { response in
            print(response)
            self.results.append(Pair(key: section, value: response))
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.reuseId, for: indexPath) as! SectionCell
        cell.configure(with: results[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pair = results.remove(at: indexPath.item)
            sections.remove(pair.key)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}



class SectionCell: UITableViewCell {
    static var reuseId = String(describing: self)
    
    func configure(with pair: Pair<Course.Section, MTResponse>) {
        self.textLabel?.text = "\(pair.key.parentId ?? "") \(pair.key.id ?? "")"
        self.detailTextLabel?.text = pair.value.seats?["remaining"] as? String
        self.imageView?.image = UIImage(systemName: "checkmark.seal.fill")
    }
    
    let statusImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "confirmation")
        return image
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(statusImage)
        
        NSLayoutConstraint.activate([
            statusImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            statusImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusImage.heightAnchor.constraint(equalToConstant: 40),
            statusImage.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


struct Pair<K, V> {
    let key: K
    let value: V
}
