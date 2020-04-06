//
//  TrackedableViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 24.03.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreData
import Groot
import Alamofire

class TrackedableViewController: ColumnViewController<Section, SectionCell> {

    var controller: NSFetchedResultsController<Section>!
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refresh
    }()
    
    
    override init(columns: Int = 1) {
        super.init(columns: columns)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTrackingRequest(_:)), name: .newTrackRequest, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tracked Courses"
        
        let request: NSFetchRequest<Section> = Section.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.predicate = NSPredicate(format: "tracked = %d", true)
        controller = NSFetchedResultsController<Section>(fetchRequest: request, managedObjectContext: CoreDataStack.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        try? controller.performFetch()
        
        let left = UISwipeGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        left.direction = .left
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        right.direction = .right
        
        collectionView.addSubview(refresh)
        collectionView.addGestureRecognizer(left)
        collectionView.addGestureRecognizer(right)
        collectionView.alwaysBounceVertical = true
        
        self.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl) {
        guard let sections = controller.fetchedObjects else { refresh.endRefreshing(); return }
        
        let group = DispatchGroup()
        
        for section in sections {
            group.enter()
            ServerManager.shared.seats(to: section) { dict in
                if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
                    section.seats = seats
                    self.update(section: section)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.reloadData()
            refresh.endRefreshing()
        }
    }
    
    @objc func didReceiveTrackingRequest(_ notification: Notification) {
        if let section = notification.object as? Section {
            section.tracked = true
            reloadData()
            ServerManager.shared.seats(to: section) { [weak self] dict in
                if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
                    seats.section = section
                    self?.update(section: section)
                    self?.reloadData()
                }
            }
        }
    }
    
    func update(section: Section) {
        if let indexPath = controller.indexPath(forObject: section), let cell = collectionView.cellForItem(at: indexPath) as? SectionCell {
            cell.configure(with: section)
        }
    }
    
    var isDeleting: Bool = false
    @objc func didLongPress(_ recognizer: UISwipeGestureRecognizer) {
        let location = recognizer.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        let cell = collectionView.cellForItem(at: indexPath) as! SectionCell
        
        if recognizer.direction == .left {
            UIView.animate(withDuration: 0.2, animations: {
                cell.center.x = 0
            }) { _ in
                let section = self.controller.object(at: indexPath)
                section.tracked = false
                self.reloadData()
            }
        }
    }
    
    func reloadData() {
        try? CoreDataStack.shared.container.viewContext.save()
        try? controller.performFetch()
        guard let sections = controller.fetchedObjects else { return }
        var snapshot = NSDiffableDataSourceSnapshot<String, Section>()
        snapshot.appendSections(["Default"])
        snapshot.appendItems(sections)
        dataSource.apply(snapshot)
    }

}

struct MTResponse: Mappable {
    
    var crn: String?
    var seats: [String: Any]?
    var waitlist: [String: Any]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        crn <- map["crn"]
        seats <- map["data.seats"]
        waitlist <- map["data.waitlist"]
    }
}

