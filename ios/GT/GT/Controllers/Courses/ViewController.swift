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

final class ViewController: ColumnViewController<Course, CourseCell>, UICollectionViewDelegate {
    var searchBar: UISearchController!
    var fetchController: NSFetchedResultsController<Course>?
    var spinner: SpinnerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Courses"
        collectionView.delegate = self
        
        fetchController = CoreDataStack.shared.loadData(sortedBy: "school", "number")
        if fetchController == nil || fetchController?.fetchedObjects == [] {
            spinner = SpinnerViewController()
            CoreDataStack.shared.downloadData() { success in
                self.fetchController = CoreDataStack.shared.loadData(sortedBy: "school", "number")
                self.spinner?.stop()
                self.spinner = nil
                self.reloadData()
            }
        } else {
            self.reloadData()
        }
    
        print(CoreDataStack.shared.container.persistentStoreCoordinator.persistentStores.map { $0.url })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinner?.start()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            let searchVC = SearchViewController(columns: 1)
            searchVC.section = header.title.text
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
    func reloadData() {
        guard let sections = fetchController?.sections else { return }
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        for section in sections {
            snapshot.appendSections([section.name])
            snapshot.appendItems(section.objects as! [Course], toSection: section.name)
        }
        dataSource.apply(snapshot)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = fetchController?.object(at: indexPath)
        let detailVC = DetailViewController()
        detailVC.course = course
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
