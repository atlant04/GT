//
//  ViewController.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import Combine
import MBProgressHUD

extension Results {
    mutating func sort(byKeyPath keyPath: String, ascending: Bool = true) {
        self = sorted(byKeyPath: keyPath, ascending: true)
    }
    
    mutating func sort<T>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) where T: Comparable {
        let string = NSExpression(forKeyPath: keyPath).keyPath
        self = sorted(byKeyPath: string, ascending: ascending)
    }

    
    mutating func filtered(_ predicateFormat: String, _ args: Any...) {
        self = filter(predicateFormat, args)
    }
}

final class ViewController: ColumnViewController<Course, CourseCell>, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate {
    var searchBar: UISearchController!
    var spinner: SpinnerViewController?
    
    var rightButton: UIBarButtonItem!
    var dropDown = DropDownTableView()
    
    var bag: AnyCancellable?
    var hud: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Courses"
        collectionView.delegate = self
        rightButton = UIBarButtonItem(title: AppConstants.currentTerm, style: .plain, target: self, action: #selector(termButtonTapped))
        
        let window = UIApplication.shared.windows.first!
        hud = MBProgressHUD.showAdded(to: window, animated: true)
        bag = store.publisher.sink { [unowned self] courses in
            self.hud?.hide(animated: true)
            self.reloadData(courses: courses)
        }
    }

    
    @objc func termButtonTapped() {
        dropDown.modalPresentationStyle = .popover
        dropDown.popoverPresentationController?.barButtonItem = rightButton
        dropDown.popoverPresentationController?.delegate = self
        dropDown.popoverPresentationController?.passthroughViews = [view]
        self.present(dropDown, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),
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
            sectionHeader?.seeAllButton.tag = indexPath.section
            sectionHeader?.seeAllButton.addTarget(self, action: #selector(self.seeAllTapped(_:)), for: .touchUpInside)
            return sectionHeader
        }
    }
    
    
    @objc func seeAllTapped(_ sender: UIButton) {
        let view = dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: sender.tag))
        
        if let header = view as? SectionHeader {
            let searchVC = SearchViewController(columns: 1)
            searchVC.section = header.title.text
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
    
    func reloadData(courses: [Course]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        let schools = courses.map(\.school).unique().sorted()
        snapshot.appendSections(schools)

        for course in courses {
            snapshot.appendItems([course], toSection: course.school)
        }

        dataSource.apply(snapshot)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let course = self.dataSource.itemIdentifier(for: indexPath) {
            let detailVC = CourseDetailViewConroller(course: course)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        var set = Set<Element>()
        return self.filter { set.insert($0).inserted }
    }
}

extension Sequence {
    func group<T>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] where T: Hashable {
        var dict: [T: [Element]] = [:]
        for element in self {
            let key = element[keyPath: keyPath]
            if case nil = dict[key]?.append(element) {
                dict[key] = [element]
            }
        }
        return dict
    }
}
