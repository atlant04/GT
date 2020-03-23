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

class ViewController: UIViewController, UICollectionViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var collectionView: UICollectionView!
    var courses = [Course]()
    var mappedCourses: [Course.School: [Course]] = [:]
    var searchedCourses = [Course]()
    var dataSource: UICollectionViewDiffableDataSource<Course.School, Course>!
    var searchBar: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Courses"
        setupCollectionView()
        view.addSubview(collectionView)
        
        searchBar = UISearchController()
        searchBar.searchResultsUpdater = self
        searchBar.delegate = self
        navigationItem.searchController = searchBar
        createDataSource()
        
        ServerManager.shared.getCourses { courses in
            self.courses = courses
            self.reloadData(with: courses)
        }
    }
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CourseCell.self, forCellWithReuseIdentifier: CourseCell.reuseIdentifier.rawValue)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.count > 0 {
            searchedCourses = self.courses.filter({ (course) -> Bool in
                course.fullname?.contains(text) ?? false ||
                    course.identifier?.contains(text) ?? false ||
                    course.identifier?.contains(text) ?? false
            })
            reloadData(with: searchedCourses)
        }
    }
    
    
    func configure<T: SelfConfiguringCell>(_ type: T.Type, with course: Course, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier.rawValue, for: indexPath) as? T else { fatalError("Unable to Dequeue")
            
        }
        cell.configure(with: course)
        return cell
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Course.School, Course>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, course) -> UICollectionViewCell? in
            return self.configure(CourseCell.self, with: course, for: indexPath)
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SectionHeader
            
            let course = self.dataSource.itemIdentifier(for: indexPath)
            sectionHeader?.title.text = course?.school?.rawValue
            return sectionHeader
        }
    }
    
    func reloadData(with courses: [Course]) {
        var snapshot = NSDiffableDataSourceSnapshot<Course.School, Course>()
        self.mappedCourses = Dictionary(grouping: courses, by:{ return $0.school ?? .CS })
        snapshot.appendSections(Array(self.mappedCourses.keys))
        
        self.mappedCourses.keys.forEach { (school) in
            snapshot.appendItems(self.mappedCourses[school] ?? [], toSection: school)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { index, environment in
            return self.createLayoutSection(using: .main)
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    func createLayoutSection(using section: Section) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let section = NSCollectionLayoutSection(group: group)
        let boundaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(40))
        let boundaryItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: boundaryItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [boundaryItem]
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { fatalError("Unable to identify") }
        presentAlert(for: item)
    }
    
    func presentAlert(for course: Course) {
        var sectionIds = ""
        sectionIds = course.sections?.reduce(sectionIds) { (ids, section)  in
            return ids + "\(section.id ?? ""), "
        } ?? "No sections exist for this course"
        
        let text = """
        Semester: \(String(describing: course.semester))\n
        Identifier: \(String(describing: course.identifier))\n
        Location: \(course.sections?.first?.meetings?.first?.location ?? "None")\n
        Time: \(course.sections?.first?.meetings?.first?.time ?? "None")\n
        Sections: \(sectionIds)
        """
        
        
        let alertVC = UIAlertController(title: course.name, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
            alertVC.dismiss(animated: true, completion: nil)
            let detailVC = DetailCourseViewController()
            detailVC.course = course
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        let monitor = UIAlertAction(title: "Monitor", style: .default) { (action) in
            ServerManager.shared.listen(to: course) { responses in
                self.presentSeatsAlert(for: responses)
            }
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(action)
        alertVC.addAction(monitor)
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension ViewController {
    enum Section {
        case main
    }
}

extension ViewController {
    
    func presentSeatsAlert(for responses: [Response]) {
        var text = ""
        text = responses.reduce(text){ (t, response) in
            guard let crn = response.crn, let seats = response.seats?["remaining"] else { return text }
            return t + "\(crn) has \(seats) seats remaining\n"
        }
        
        let alertVC = UIAlertController(title: "Availability", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { action in alertVC.dismiss(animated: true, completion: nil) }
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}


struct Response: Mappable {
    
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
