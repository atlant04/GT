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
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTrackAllRequest(_:)), name: .trackAllRequest, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tracked Courses"
        
        let request: NSFetchRequest<Section> = Section.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.predicate = NSPredicate(format: "tracked = %d", true)
        controller = NSFetchedResultsController<Section>(fetchRequest: request, managedObjectContext: CoreDataStack.shared.container.viewContext, sectionNameKeyPath: "course.identifier", cacheName: nil)
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
    
    override func registerCells() {
        super.registerCells()
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
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
                    //self.update(section: section)
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
            ServerManager.shared.seats(to: section) { [weak self] dict in
                if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
                    seats.section = section
                    section.tracked = true
                    //self?.update(section: section)
                    self?.reloadData()
                }
            }
        }
    }
    
    @objc func didReceiveTrackAllRequest(_ notification: Notification) {
        if let sections = notification.object as? [Section] {
//            for section in sections {
//                section.tracked = true
//                reloadData()
//                ServerManager.shared.seats(to: section) { [weak self] dict in
//                    if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
//                        seats.section = section
//                        self?.update(section: section)
//                        self?.reloadData()
//                    }
//                }
//            }
            
            let group = DispatchGroup()
            
            for section in sections {
                group.enter()
                ServerManager.shared.seats(to: section) { dict in
                    if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
                        seats.section = section
                        section.tracked = true
                        //self.update(section: section)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.reloadData()
            }
        }
    }
    
    func update(section: Section) {
        if let indexPath = controller.indexPath(forObject: section), let cell = collectionView.cellForItem(at: indexPath) as? SectionCell {
            cell.configure(with: section)
        }
    }
    
    
    override func createLayoutSection(forSectionIndex sectionIndex: Int, andLayoutEnvironment layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.97), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 1)
        let section = NSCollectionLayoutSection(group: group)
        
        let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(44))
        let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: titleSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.boundarySupplementaryItems = [titleSupplementary]
        return section
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
                ServerManager.shared.unsubscribe(from: section) { response in }
            }
        }
    }
    
    func reloadData() {
        try? CoreDataStack.shared.container.viewContext.save()
        try? controller.performFetch()
        
        for section in controller.sections ?? [] {
                   print(section)
                   for object in section.objects ?? [] {
                       print(object)
                   }
               }
        
        guard let sections = controller.sections else { return }
        var snapshot = NSDiffableDataSourceSnapshot<String, Section>()
        for section in sections {
            print(section.name)
            snapshot.appendSections([section.name])
            snapshot.appendItems(section.objects as! [Section], toSection: section.name)
        }
        dataSource.apply(snapshot)
    }
    
    override func setupDataSource() {
        super.setupDataSource()
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SectionHeader
            let name = self.controller.sections?[indexPath.section].name
            sectionHeader?.title.text = name
            sectionHeader?.seeAllButton.isHidden = true
            return sectionHeader
        }
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

