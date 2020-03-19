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
        navigationItem.title = "Courses"
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
//        let nib = UINib(nibName: "CourseCellXib", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: CourseCellXib.reuseIdentifier.rawValue)
        collectionView.register(CourseCell.self, forCellWithReuseIdentifier: CourseCell.reuseIdentifier.rawValue)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        view.addSubview(collectionView)

        searchBar = UISearchController()
        searchBar.searchResultsUpdater = self
        searchBar.delegate = self
        navigationItem.searchController = searchBar
        createDataSource()

        AF.request("https://oscarapp.appspot.com/courses", method: .get).responseJSON { response in
            switch response.result {
            case .success(let json):
                //print(jsonString.prefix(1000))
                do {
                    self.courses = try Mapper<Course>().mapArray(JSONObject: json)
                } catch {
                    print(error)
                }
                self.reloadData(with: self.courses)
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }

     func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.count > 0 {
            searchedCourses = self.courses.filter({ (course) -> Bool in
                course.fullname.contains(text) || course.identifier.contains(text) || course.identifier.contains(text) 
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
            sectionHeader?.title.text = course?.school.rawValue
            return sectionHeader
        }
    }

    func reloadData(with courses: [Course]) {
        var snapshot = NSDiffableDataSourceSnapshot<Course.School, Course>()
        self.mappedCourses = Dictionary(grouping: courses, by:{ $0.school })
        snapshot.appendSections(Array(self.mappedCourses.keys))

        self.mappedCourses.keys.forEach { (school) in
            snapshot.appendItems(self.mappedCourses[school] ?? [], toSection: school)
        }

        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { index, environment in
            print(index)
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

        let text = """
        Semester: \(item.semester)\n
        Identifier: \(item.identifier)\n
        Section 1: \(item.sections?.first?.id ?? "None")\n
        Location: \(item.sections?.first?.meetings.first?.location ?? "None")\n
        Time: \(item.sections?.first?.meetings.first?.time ?? "None")\n
        Instructor: \(item.sections?.first?.meetings.first?.instructor.first ?? "None")
        """

        let alertVC = UIAlertController(title: item.name, message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
            alertVC.dismiss(animated: true, completion: nil)
            let detailVC = DetailCourseViewController()
            detailVC.course = item
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension ViewController {
    enum Section {
        case main
    }
}
