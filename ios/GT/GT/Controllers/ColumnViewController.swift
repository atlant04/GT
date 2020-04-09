//
//  TwoColumnViewController.swift
//  GT
//
//  Created by Maksim Tochilkin on 04.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


class ColumnViewController<T: Hashable, Cell: UICollectionViewCell>: UICollectionViewController where Cell: ConfiguringCell, Cell.Content == T{
    var dataSource: UICollectionViewDiffableDataSource<String, T>!
    var columnNumber: Int
    
    init(columns: Int = 1) {
        columnNumber = columns
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.collectionViewLayout = createCompositionalLayout()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        setupDataSource()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
    }
    
    
    //MARK: Layout
    func createCompositionalLayout(section: NSCollectionLayoutSection? = nil) -> UICollectionViewCompositionalLayout {
        return createLayout()
    }
    
    func createLayoutSection(forSectionIndex sectionIndex: Int,
                             andLayoutEnvironment layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: layoutEnvironment.container.effectiveContentSize.width > 500 ? columnNumber + 1 : columnNumber)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
//    let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                          heightDimension: .estimated(44))
//    let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
//        layoutSize: titleSize,
//        elementKind: SectionHeader.titleElementKind,
//        alignment: .top)
//    section.boundarySupplementaryItems = [titleSupplementary]
    
    func createLayout() -> UICollectionViewCompositionalLayout {

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        let sectionProvider = { [weak self] (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            return self.createLayoutSection(forSectionIndex: sectionIndex,
                                            andLayoutEnvironment: layoutEnvironment)
        }
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
        
    }
    
    typealias CellConfigurator<CellType: UICollectionViewCell> = (T, IndexPath) -> CellType where CellType: ConfiguringCell
    
    func registerCells(){
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    }
    
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<String, T>(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return self.configure(with: item, for: indexPath)
        })
    }
    
    func configure(with item: T, for indexPath: IndexPath) -> Cell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else { fatalError("Unable to Dequeue") }
        cell.configure(with: item)
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}


protocol ConfiguringCell {
    associatedtype Content
    static var reuseIdentifier: String { get }
    func configure(with content: Content)
}
