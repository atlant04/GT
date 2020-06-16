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

    var controller: NSFetchedResultsController<Section> = {
        let request: NSFetchRequest<Section> = Section.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.predicate = NSPredicate(format: "crn = '35859'", true)
        let controller = NSFetchedResultsController<Section>(fetchRequest: request, managedObjectContext: CoreDataStack.shared.container.viewContext, sectionNameKeyPath: "course.identifier", cacheName: nil)
        return controller
    }()

    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return refresh
    }()


    var trackedSections: [String: Set<Section>] = [:]
    var sectionsAsArray: [Section] {
        return Array(trackedSections.values).flatMap{ $0 }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        overlay.animate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        overlay.zeroAlpha()
    }
    
    override init(columns: Int = 1) {
        super.init(columns: columns)
//        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTrackingRequest(_:)), name: .newTrackRequest, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTrackAllRequest(_:)), name: .trackAllRequest, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Tracked Courses"

        if let _ = try? controller.performFetch(), let sections = controller.fetchedObjects {
            trackedSections = Dictionary<String, Set<Section>>()
            sections.forEach { self.append(section: $0) }
            update()
        }


        let left = UISwipeGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        left.direction = .left
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        right.direction = .right
        
        collectionView.addSubview(refresh)
        collectionView.addGestureRecognizer(left)
        collectionView.addGestureRecognizer(right)
        collectionView.alwaysBounceVertical = true
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        view.fill(with: overlay)

    }
    let overlay = OverlayView()
    
    class OverlayView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
            let stack = UIStackView(arrangedSubviews: [comingSoon, message])
            stack.axis = .vertical
            addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.centerYAnchor.constraint(equalTo: centerYAnchor),
                stack.centerXAnchor.constraint(equalTo: centerXAnchor),
                stack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8)
            ])
        }
        
        lazy var comingSoon: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 1
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.text = "Coming soon..."
            label.alpha = 0
            label.textColor = traitCollection.userInterfaceStyle == .light ? .black : .white
            label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            return label
        }()
        
        lazy var message: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 4
            label.textAlignment = .center
            label.alpha = 0
            label.adjustsFontSizeToFitWidth = true
            label.textColor = traitCollection.userInterfaceStyle == .light ? .black : .white
            label.text = "Live course availability tracking with notifications when more spots open up for you"
            label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            return label
        }()
        
        func animate() {
            UIView.animate(withDuration: 1, delay: 0.5, animations: {
                self.comingSoon.alpha = 1
            }, completion: {_ in})
            
            UIView.animate(withDuration: 1, delay: 1.5, animations: {
                self.message.alpha = 1
            }, completion: {_ in})
        }
        
        func zeroAlpha() {
            comingSoon.alpha = 0
            message.alpha = 0
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    
    override func registerCells() {
        super.registerCells()
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleRefresh(_ refresh: UIRefreshControl) {
        guard !trackedSections.isEmpty else { refresh.endRefreshing(); return }
        
        let group = DispatchGroup()
        
        for section in sectionsAsArray {
            group.enter()
//            ServerManager.shared.seats(to: section) { [weak self] dict in
//                if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
//                    section.seats = seats
//                    self?.updateCell(section: section)
//                }
//                 group.leave()
//            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            refresh.endRefreshing()
            self.update()
        }
    }
    
    @objc func didReceiveTrackingRequest(_ notification: Notification) {
        if let section = notification.object as? Section {
            section.tracked = true
            append(section: section)
            update()
            ServerManager.shared.seats(to: section) { [weak self] dict in
                if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
                    section.seats = seats
                    section.tracked = true
                    self?.updateCell(section: section)
                }
            }
        }
    }

    func append(section: Section) {
        guard let id = section.course?.identifier else { return }
        if let _ = trackedSections[id] {
            trackedSections[id]?.insert(section)
        } else {
            trackedSections[id] = [section]
        }
    }

    func remove(_ section: Section) {
        guard let id = section.course?.identifier else { return }
        trackedSections[id]?.remove(section)
        if trackedSections[id]?.isEmpty ?? false {
            trackedSections.removeValue(forKey: id)
        }
    }
    
    @objc func didReceiveTrackAllRequest(_ notification: Notification) {
        guard let sections = notification.object as? [Section] else { return }

        let group = DispatchGroup()
        for section in sections {
            append(section: section)
            group.enter()
            ServerManager.shared.seats(to: section) { [weak self] dict in
                if let seats = try? object(withEntityName: "Seats", fromJSONDictionary: dict, inContext: CoreDataStack.shared.container.viewContext) as? Seats {
                    seats.section = section
                    section.tracked = true
                    self?.updateCell(section: section)
                    group.leave()
                }
            }
        }

        update()
            
        group.notify(queue: .main) {

        }
    }
    
    func updateCell(section: Section) {
        try? CoreDataStack.shared.container.viewContext.save()
        if let indexPath = dataSource.indexPath(for: section), let cell = collectionView.cellForItem(at: indexPath) as? SectionCell {
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
                if let section = self.dataSource.itemIdentifier(for: indexPath) {
                    self.remove(section)
                    self.update()
                    section.tracked = false
                    ServerManager.shared.unsubscribe(from: section) { response in }
                }
            }
        }
    }

    func update() {
        var snapshot = NSDiffableDataSourceSnapshot<String, Section>()
        snapshot.appendSections(Array(trackedSections.keys))
        print(trackedSections)
        for (id, sections) in trackedSections {
            snapshot.appendItems(Array(sections), toSection: id)
        }

        dataSource.apply(snapshot)
    }
    
    override func setupDataSource() {
        super.setupDataSource()
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SectionHeader
            let section = self.dataSource.itemIdentifier(for: indexPath)
            sectionHeader?.title.text = section?.course?.identifier
            sectionHeader?.seeAllButton.isHidden = true
            return sectionHeader
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? CoreDataStack.shared.container.viewContext.save()
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

