//
//  ViewController.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import CoreData

final class ViewController: ColumnViewController<Course, CourseCell> {
    var searchBar: UISearchController!
    var fetchController: NSFetchedResultsController<Course>!
    var spinner: SpinnerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Courses"
        loadCourses()

        if fetchController.fetchedObjects?.count == 0 {
            spinner = SpinnerViewController()
            ServerManager.shared.getCourses { dict in
                CoreDataStack.shared.insertCourses(dict) { success in
                    if success {
                        self.spinner?.stop()
                        self.spinner = nil
                        self.loadCourses()
                        self.reloadData()
                        print(schoolColors)
                    }
                }
            }
        } else {
            self.reloadData()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner?.start()
    }
    
    func loadCourses() {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "school", ascending: true), NSSortDescriptor(key: "number", ascending: true)]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.shared.container.viewContext, sectionNameKeyPath: "school", cacheName: nil)
        
        do {
            try fetchController.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func registerCells() {
        super.registerCells()
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    override func createLayoutSection(forSectionIndex sectionIndex: Int,
                             andLayoutEnvironment layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupFractionalWidth = CGFloat(layoutEnvironment.container.effectiveContentSize.width > 500 ?
            0.3 : 0.44)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupFractionalWidth),
                                              heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .estimated(40))
        let boundaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize,
                                                                       elementKind: UICollectionView.elementKindSectionHeader,
                                                                       alignment: .top)
        section.boundarySupplementaryItems = [boundaryItem]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
        
    }
    
    override func setupDataSource() {
        super.setupDataSource()
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SectionHeader
            let course = self.dataSource.itemIdentifier(for: indexPath)
            sectionHeader?.title.text = course?.school
            sectionHeader?.seeAllButton.addTarget(self, action: #selector(self.seeAllTapped(_:)), for: .touchUpInside)
            return sectionHeader
        }
    }
    
    
    @objc func seeAllTapped(_ sender: UIButton) {
        var view: UIView = sender
        
        while let superview = view.superview {
            if superview is SectionHeader {
                view = superview as! SectionHeader
                break;
            } else {
                view = superview
            }
            print(view)
        }
        if let header = view as? SectionHeader {
            let searchVC = SearchViewController()
            searchVC.section = header.title.text
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
    func reloadData() {
        guard let sections = fetchController.sections else { return }
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        for section in sections {
            snapshot.appendSections([section.name])
            snapshot.appendItems(section.objects as! [Course], toSection: section.name)
        }
        dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let course = fetchController.object(at: indexPath)
        let detailVC = DetailViewController()
        detailVC.course = course
        print(course.sections)
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
