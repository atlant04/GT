//
//  CourseDetailViewConroller.swift
//  GT
//
//  Created by Maksim Tochilkin on 22.07.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import SwiftUI
import MTWeekView
import Segmentio
import MTLayout

final class WeekViewCell: UICollectionViewCell, ConfiguringCell {
    typealias Content = Never
    var weekView: MTWeekView! {
        didSet {
            commonInit()
        }
    }
    
    class EventCell: MTBaseCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.contentView.layer.cornerRadius = 4
            self.contentView.layer.cornerCurve = .continuous
            self.contentView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func commonInit() {
        self.weekView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(weekView)
        self.contentView.fill(with: weekView)
    }
    
}

final class CDSectionPickerCell: UICollectionViewCell {
    
    let name = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.name.textAlignment = .center
        self.contentView.addSubview(name)
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.borderWidth = 3
        self.contentView.layer.cornerCurve = .continuous
        
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
    }
    
    //    override func draw(_ rect: CGRect) {
    //        let height = self.bounds.height
    //        let width = self.bounds.width
    //
    //        let shadowSize: CGFloat = 20
    //        self.layer.shadowPath = UIBezierPath(rect: self.bounds.offsetBy(dx: 0, dy: 10)).cgPath
    //    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.name.frame = self.bounds
    }
    
    override var intrinsicContentSize: CGSize {
        return name.intrinsicContentSize
    }
}

final class CourseDetailViewConroller: UIViewController, MTWeekViewDataSource {
    enum ViewSection: CaseIterable {
        case main
        case calendar
    }
    
    struct Item: Hashable {
        var mainLabel: String?
        var secondaryLabel: String
        var state: LoadingState
        
        init(mainLabel: String?, secondaryLabel: String) {
            self.mainLabel = mainLabel
            self.secondaryLabel = secondaryLabel
            self.state = mainLabel == nil ? .loading : .loaded(mainLabel!)
        }
        
        enum LoadingState: Hashable {
            case loading
            case loaded(String)
        }
    }
    
    let course: Course
    var sectionList: Segmentio!
    var data: [Item] = []
    var weekView: MTWeekView?
    var prereqTable: PrereqAndRestrictionTable
    
    init(course: Course) {
        self.course = course
        prereqTable = PrereqAndRestrictionTable(course: course)
        super.init(nibName: nil, bundle: nil)
        
        CourseCritiqueAPI.fetch(course: course) { [weak self] gpa in
            self?.updateLoadingItems(gpa: gpa)
        }
        
        data = [
            Item(mainLabel: "\(course.sections?.count ?? 0)", secondaryLabel: "Sections"),
            Item(mainLabel: "\(course.gradeBasis)", secondaryLabel: "Grade Basis"),
            Item(mainLabel: "\(course.semester)", secondaryLabel: "Semester"),
            Item(mainLabel: nil, secondaryLabel: "Average GPA"),
            Item(mainLabel: "34+", secondaryLabel: "Sections"),
            Item(mainLabel: "Sync", secondaryLabel: "Instruction Mode")
        ]
        
        preferredContentSize = CGSize(width: 1000, height: 1200)
    }
    
    func updateLoadingItems(gpa: Double?) {
        let string = gpa == nil ? "None" : "\(gpa!)"
        
        var item = self.data[3]
        guard let indexPath = self.dataSource.indexPath(for: item) else { return }
        let cell = self.collectionView.cellForItem(at: indexPath) as! DetailViewCell
        
        item.state = .loaded(string)
        cell.configure(with: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var collectionView: DetailCollectionView = DetailCollectionView()
    
    var dataSource: UICollectionViewDiffableDataSource<ViewSection, Item>!
    typealias CellConfigurator = UICollectionViewDiffableDataSource<ViewSection, Item>.CellProvider
    
    func allEvents(for weekView: MTWeekView) -> [Event] {
        selectedSection?.events ?? course.events ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = course.identifier
        self.view.backgroundColor = .white
        self.setupCollectionView()
        self.setupDatasource()
        self.setupSectionPicker()
        self.setupTable()
        self.reloadData()
        
        self.view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupTable() {
        self.view.addSubview(prereqTable)
        prereqTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prereqTable.topAnchor.constraint(equalTo: sectionList.bottomAnchor),
            prereqTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            prereqTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            prereqTable.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    var selectedSection: Section? {
        didSet {
            weekView?.reload()
        }
    }
    
    func setupSectionPicker() {
        sectionList = Segmentio()
        sectionList.backgroundColor = .systemGroupedBackground
        let items = self.course.sections?.map { SegmentioItem(title: $0.id, image: nil) } ?? []
        var options = SegmentioOptions(backgroundColor: .systemGroupedBackground,
                                       segmentPosition: .dynamic,
                                       indicatorOptions: .init(type: .bottom, color: .systemBlue, roundedCorners: true),
                                       horizontalSeparatorOptions: nil)
        
        options.verticalSeparatorOptions = .init(ratio: 0.5, color: .black)
        sectionList.cellConfigurator = { cell, index, item in
            cell.containerView?.layer.cornerRadius = 12
            cell.containerView?.backgroundColor = .white
        }
        sectionList.setup(content: items, style: .onlyLabel, options: options)
        sectionList.translatesAutoresizingMaskIntoConstraints = false
        sectionList.valueDidChange = { [unowned self] segmention, index in
            self.selectedSection = self.course.sections?[index]
        }
        self.view.addSubview(sectionList)
        sectionList.isHidden = course.sections?.isEmpty ?? true
        NSLayoutConstraint.activate([
            sectionList.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            sectionList.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            sectionList.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            sectionList.heightAnchor.constraint(equalToConstant: 70)
        ])

    }
    
    func setupCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        var config = LayoutConfiguration()
        config.hidesVerticalLines = true
        config.timelineWidth = 0
        
        weekView = MTWeekView(frame: .zero, configuration: config)
        weekView?.backgroundColor = .systemGroupedBackground
        weekView?.collectionView.backgroundColor = .systemGroupedBackground
        weekView?.register(WeekViewCell.EventCell.self)
        weekView?.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    
    func setupDatasource() {
        
        let provider: CellConfigurator = { [unowned self] collection, index, item -> UICollectionViewCell? in
            
            if index.row == 2 {
                let cell = collection.dequeueReusableCell(withReuseIdentifier: WeekViewCell.reuseIdentifier, for: index) as! WeekViewCell
                cell.weekView = self.weekView
                cell.contentView.backgroundColor = .secondarySystemGroupedBackground
                return cell
            }
            
            let cell = collection.dequeueReusableCell(withReuseIdentifier: DetailViewCell.reuseIdentifier, for: index) as! DetailViewCell
            cell.configure(with: item)
            
            return cell
        }
        
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: provider)
    }
    
    func reloadData() {
        var snap = NSDiffableDataSourceSnapshot<ViewSection, Item>()
        
        snap.appendSections([.main])
        snap.appendItems(self.data)
        dataSource.apply(snap)
    }
    
    
}

extension FloatingPoint {
    func map(from: Self, to: Self, between: Self, and: Self) -> Self {
        return (self - from) / (to - from) * (and - between) + between
    }
}


#if DEBUG
import SwiftUI
typealias VC = CourseDetailViewConroller

struct Preview_Gridw: PreviewProvider {
    static var previews: some View {
        UINavigationController(rootViewController: VC()).preview
        //        VC().preview
    }
}
#endif

/*
 let layout = Section {
 Horizontal(w: Smth, h: Smth) {
 Item
 Item
 Vertical {
 Item
 Item
 }
 }
 .fractionalSize(w: asd, h: asd)
 }
 
 protocol Item {
 
 }
 
 
 
 */

class DetailCollectionView: UICollectionView {
    typealias DataDict = [CourseDetailViewConroller.ViewSection: [CourseDetailViewConroller.Item]]
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: Self.createLayout())
        self.register(UINib(nibName: "DetailViewCell", bundle: nil), forCellWithReuseIdentifier: DetailViewCell.reuseIdentifier)
        self.register(WeekViewCell.self, forCellWithReuseIdentifier: WeekViewCell.reuseIdentifier)
        self.backgroundColor = .systemBackground
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func createLayout() -> UICollectionViewLayout {
        
        let group: MTLayout.Section = MTLayout.Section {
            VGroup {
                HGroup {
                    VGroup {
                        Item()
                        Item()
                    }
                    Item()
                }
                .distribute([1, 3])
                
                HGroup {
                    Item()
                    Item()
                    Item()
                }
            }
            .distribute([2, 1])
        }
        
        
        let section = NSCollectionLayoutSection(group: group.group!.layoutGroup())
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

