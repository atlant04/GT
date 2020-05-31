//
//  SearchViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: ColumnViewController<Course, CourseCell>, UIPopoverPresentationControllerDelegate {
    let search = UISearchController()
    var request: NSFetchRequest<Course> = Course.fetchRequest()
    var controller: NSFetchedResultsController<Course>?

    var onSelected: ((Course, SearchViewController) -> Void) = { course, vc  in
        vc.presentDetailVC(course: course)
    }

    var section: String? {
        didSet {
            searchCourses(text: self.section)
        }
    }
    
    var configView = ConfigView()
    var configBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = search
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        configView.searchVC = self
        configView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        search.searchBar.searchTextField.inputAccessoryView = configView
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        
        request.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        searchCourses(text: section)
        configBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleConfig))
        navigationItem.rightBarButtonItem = nil//configBarButton
        modalPresentationStyle = .none
    }
    
    let configVC = SerchConfigViewController()
    @objc
    func handleConfig() {
        configVC.modalPresentationStyle = .popover
        configVC.preferredContentSize = CGSize(width: 200, height: 200)
        configVC.popoverPresentationController?.delegate = self
        configVC.popoverPresentationController?.passthroughViews = [view]
        (configVC.view as? ConfigView)?.searchVC = self
        if let popverVC = configVC.popoverPresentationController {
            popverVC.barButtonItem = configBarButton
            present(configVC, animated: true, completion: nil)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }

    func presentDetailVC(course: Course) {
        let detailVC = DetailViewController()
        detailVC.course = course
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configVC.dismiss(animated: true, completion: nil)
    }
    
    func searchCourses(text: String?) {
        request.predicate = createPredicate(text: text)
        request.sortDescriptors = [.init(key: "number", ascending: true)]
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
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        snapshot.appendSections(["Default"])
        snapshot.appendItems(controller?.fetchedObjects ?? [])
        dataSource.apply(snapshot)
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

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let controller = controller else { return }
        let course = controller.object(at: indexPath)
        onSelected(course, self)
    }
}
