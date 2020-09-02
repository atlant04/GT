//
//  CourseAdderTableViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import Combine

final class CourseAdderTableViewController: UITableViewController, UISearchResultsUpdating {
    let search = UISearchController()
    
    let table = CourseAdderTableView()
    let customView: ContainverView
    var schedule: Schedule
    
    var searchObject = PassthroughSubject<[Course], Never>()
    var tapDelegate = PassthroughSubject<(ScheduleItemHeaderView.ButtonType, Int), Never>()
    
    var collapsedSections = Set<Int>()
    
    init(schedule: Schedule) {
        self.customView = ContainverView(frame: .zero, view: table)
        self.schedule = schedule
        super.init(style: .plain)
        customView.layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        customView.layer.shadowOpacity = 0.6
        customView.layer.shadowOffset = CGSize(width: 0, height: 8)
        customView.layer.shadowRadius = 4
        customView.layer.shouldRasterize = true
        customView.layer.masksToBounds = false
        customView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Courses"
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = search
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        table.searchPublisher = searchObject.eraseToAnyPublisher()
        
        navigationController?.view.addSubview(customView)
        customView.isHidden = true
        
        navigationController?.navigationBar.publisher(for: \.frame).sink(receiveValue: { [unowned self] frame in
            self.customView.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 300)
        }).store(in: &bag)
        
        tapDelegate.sink { [unowned self] tuple in
            let (button, section) = tuple
            
            switch button {
            case .arrow:
                let (inserted, _) = self.collapsedSections.insert(section)
                
                if !inserted {
                    self.collapsedSections.remove(section)
                    self.tableView.insertRowsInSection(section, with: .fade)
                } else {
                    self.tableView.deleteRowsInSection(section, with: .fade)
                }
                
            default:
                break
            }
        }.store(in: &bag)
        
        table.didSelectCourse = { [unowned self] course in
            let item = ScheduleItem(color: .random, selectedSections: Set(), course: course)
            store.scheduleStore.submit(.addItem(item, self.schedule))
            self.schedule.items.append(item)
            self.search.searchBar.text = nil
            self.tableView.insertSections([0], with: .top)
        }
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(ScheduleItemDetailView.loadNib(), forCellReuseIdentifier: ScheduleItemDetailView.reuseIdentifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        schedule.items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collapsedSections.contains(section) ? 0 : schedule.items[section].course?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        120
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = ScheduleItemHeaderView.loadView() else { return nil }
        header.tag = section
        header.delegate = tapDelegate
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleItemDetailView.reuseIdentifier, for: indexPath)
        return cell
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        let hide = text == nil || text!.isEmpty
        
        if customView.isHidden && !hide {
            self.customView.frame.size.height = 0
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                self.customView.isHidden = false
                self.customView.frame.size.height = 300
            }, completion: nil)
            
        } else if !customView.isHidden && hide {
            self.customView.isHidden = true
        }
        
        searchObject.send(store.courses.filter { $0.fullname.contains(text!) })
    }
    
    var bag = Set<AnyCancellable>()
    
    
}

extension UITableView {
    func deleteRowsInSection(_ section: Int, with animation: UITableView.RowAnimation) {
        let itemCount = self.numberOfRows(inSection: section)
        let indexPaths = (0 ..< itemCount).map { IndexPath(row: $0, section: section) }
        self.deleteRows(at: indexPaths, with: animation)
    }
    
    func insertRowsInSection(_ section: Int, with animation: UITableView.RowAnimation) {
        guard let itemCount = self.dataSource?.tableView(self, numberOfRowsInSection: section) else { return }
        let indexPaths = (0 ..< itemCount).map { IndexPath(row: $0, section: section) }
        self.insertRows(at: indexPaths, with: animation)
    }
}
