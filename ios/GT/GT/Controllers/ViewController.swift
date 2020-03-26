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

class ViewController: UIViewController, UICollectionViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var collectionView: UICollectionView!
    var courses = [Course]()
    var selectedCourses = [Course]()
    var dataSource: UICollectionViewDiffableDataSource<String, Course>!
    var searchBar: UISearchController!
    var fetchController: NSFetchedResultsController<Course>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Courses"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(filterButtonTapped))
        setupCollectionView()
        view.addSubview(collectionView)
        
        searchBar = UISearchController()
        searchBar.searchResultsUpdater = self
        searchBar.delegate = self
        navigationItem.searchController = searchBar
        createDataSource()
        
        let courses = CoreDataStack.shared.fetchCourses()
//        let request = NSFetchRequest<Course>(entityName: "Course")
//        request.sortDescriptors = [
//            NSSortDescriptor(key: "name", ascending: true)
//        ]
//        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        do {
//            try fetchController.performFetch()
//        } catch {
//            print(error)
//        }
//        if let courses = fetchController.fetchedObjects {
//            self.reloadData(with: courses)
//        }
        
        if courses.count == 0 {
            ServerManager.shared.getCourses { courses in
                self.courses = courses
                self.reloadData(with: courses)
            }
        } else {
            self.courses = courses
            self.reloadData(with: courses)
            CoreDataStack.shared.saveContext()
        }
        selectedCourses = self.courses
    }
    
    @objc func filterButtonTapped() {
        let alertVC = UIAlertController(title: "Filter", message: "", preferredStyle: .actionSheet)
        let filters = ["CS", "MATH", "INTA", "PHYS", "ALL"]
        filters.forEach { title in
            let action = UIAlertAction(title: title, style: .default) { action in
                self.filter(attribute: action.title!)
                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(action)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func filter(attribute: String) {
        
        var section: NSCollectionLayoutSection? = nil
        var courses: [Course]

        if attribute == "ALL" {
            courses = self.courses
            selectedCourses = self.courses
        } else {
            courses = CoreDataStack.shared.fetchCourses(by: attribute)
            selectedCourses = courses
            section = createLayoutSection(using: .main)
            section!.orthogonalScrollingBehavior = .none
        }
        
        self.collectionView.collectionViewLayout = self.createCompositionalLayout(section: section)
        self.reloadData(with: courses)
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
            let searchedCourses = self.selectedCourses.filter({ (course) -> Bool in
                course.fullname?.contains(text) ?? false ||
                    course.identifier?.contains(text) ?? false ||
                    course.identifier?.contains(text) ?? false
            })
            reloadData(with: searchedCourses)
        }
        
//        if let text = searchController.searchBar.text, text.count > 0 {
//            let request = NSFetchRequest<Course>(entityName: "Course")
//            request.predicate = NSPredicate(format: "fullname CONTAINS[c] '\(text)'")
//            let courses = CoreDataStack.shared.fetchCourses(request: request)
//            reloadData(with: courses)
//        }
    }
    
    
    func configure<T: SelfConfiguringCell>(_ type: T.Type, with course: Course, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier.rawValue, for: indexPath) as? T else { fatalError("Unable to Dequeue")
            
        }
        cell.configure(with: course)
        return cell
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, Course>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, course) -> UICollectionViewCell? in
            return self.configure(CourseCell.self, with: course, for: indexPath)
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SectionHeader
            
            let course = self.dataSource.itemIdentifier(for: indexPath)
            sectionHeader?.title.text = course?.school
            return sectionHeader
        }
    }
    
    func reloadData(with courses: [Course]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        let mappedCourses = Dictionary(grouping: courses, by:{ return $0.school ?? "DNE" })
        snapshot.appendSections(Array(mappedCourses.keys).sorted())
        
        mappedCourses.keys.forEach { (school) in
            snapshot.appendItems(mappedCourses[school] ?? [], toSection: school)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func createCompositionalLayout(section: NSCollectionLayoutSection? = nil) -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { index, environment in
            return section ?? self.createLayoutSection(using: .main)
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
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(150))
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
        sectionIds = course.sections.reduce(sectionIds) { (ids, section)  in
            return ids + "\(section.id ?? ""), "
        }
        
        let text = """
        Semester: \(String(describing: course.semester))\n
        Identifier: \(String(describing: course.identifier))\n
        Location: \(course.sections.first?.meetings.first?.location ?? "None")\n
        Time: \(course.sections.first?.meetings.first?.time ?? "None")\n
        Sections: \(sectionIds)
        """
        
        
        let alertVC = UIAlertController(title: course.name, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
            alertVC.dismiss(animated: true, completion: nil)
            let detailVC = DetailViewController()
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
    
    func presentSeatsAlert(for responses: [MTResponse]) {
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

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let courses = controller.fetchedObjects as? [Course] {
            self.courses = courses
            self.reloadData(with: courses)
            selectedCourses = courses
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
