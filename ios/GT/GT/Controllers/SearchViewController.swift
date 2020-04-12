//
//  SearchViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: ColumnViewController<Course, CourseCell> {
    let search = UISearchController()
    
    var request: NSFetchRequest<Course> = Course.fetchRequest()
    var controller: NSFetchedResultsController<Course>?
    var section: String? {
        didSet {
            searchCourses(text: self.section)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = search
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        collectionView.backgroundColor = .systemBackground
        
        request.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        searchCourses(text: section)
        
    }
    
    func searchCourses(text: String?) {
        request.predicate = createPredicate(text: text)
        controller = NSFetchedResultsController<Course>(fetchRequest: request, managedObjectContext: CoreDataStack.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller?.performFetch()
            self.reloadData()
        } catch {
            print(error)
        }
    }
    
    func createPredicate(text: String?) -> NSPredicate? {
        let predicate: NSPredicate?
        if let section = section {
            if let text = text {
                predicate = NSPredicate(format: "school == %@ AND fullname CONTAINS[c] %@", section, text)
            } else {
                predicate = NSPredicate(format: "school == %@", section)
            }
        } else {
            if let text = text {
                predicate = NSPredicate(format: "fullname CONTAINS[c] %@", text)
            } else {
                predicate = nil
            }
        }
        return predicate
    }
}


extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchCourses(text: text)
        } else {
            searchCourses(text: section)
        }
    }
}


extension SearchViewController {
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        snapshot.appendSections(["Default"])
        snapshot.appendItems(controller?.fetchedObjects ?? [])
        dataSource.apply(snapshot)
    }
}

extension SearchViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller = controller else { return }
        let course = controller.object(at: indexPath)
        let detailVC = DetailViewController()
        detailVC.course = course
        print(course.sections)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
