//
//  SearchViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 01.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import CoreData
import SideMenu
import Combine

class SearchViewController: ColumnViewController<Course, CourseCell>, UIPopoverPresentationControllerDelegate {
    
    let search = UISearchController()
    
    var onSelected: ((Course, SearchViewController) -> Void) = { course, vc  in
        vc.presentDetailVC(course: course)
    }

    var section: String? {
        didSet {
            searchCourses(text: self.section)
        }
    }
    
    var configView = ConfigView()
    var bag = Set<AnyCancellable>()
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(presentFilterVC))
        modalPresentationStyle = .none
        
        store.publisher.sink(receiveValue: { [unowned self] courses in
            print(courses.count)
            self.reloadData(courses: courses)
            }).store(in: &bag)
    
        
    }
    
    @objc func presentFilterVC() {
        let searchNavVC = UIStoryboard(name: "Search", bundle: nil).instantiateInitialViewController() as! SideMenuNavigationController
        searchNavVC.settings.presentationStyle = .menuSlideIn
        searchNavVC.settings.pushStyle = .popWhenPossible
//        searchNavVC.settings.presentationStyle.presentingScaleFactor = 0.9
        searchNavVC.settings.presentationStyle.presentingEndAlpha = 0.8
        searchNavVC.settings.menuWidth = self.view.bounds.width * 0.75
        self.present(searchNavVC, animated: true, completion: nil)
    }
    

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }

    func presentDetailVC(course: Course) {
//        let detailVC = CourseDetailViewConroller(course: course)
//        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func searchCourses(text: String?) {
        guard let predicate = createPredicate(text: text) else { return }
//        $courses = $courses.filter(predicate)
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
    
    func reloadData(courses: [Course]) {
        var snapshot = NSDiffableDataSourceSnapshot<String, Course>()
        snapshot.appendSections(["Default"])
        snapshot.appendItems(courses)
        dataSource.apply(snapshot)
    }
}


extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            store.submit(.search(text))
        }
//        self.reloadData()
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let course = self.dataSource.itemIdentifier(for: indexPath) {
            let detail = CourseDetailViewConroller(course: course)
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
}
