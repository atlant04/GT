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
        let layout = UICollectionViewCompositionalLayout(section: createLayoutSection())
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    func createLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnNumber)
        let section = NSCollectionLayoutSection(group: group)
        return section
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
}


protocol ConfiguringCell {
    associatedtype Content
    static var reuseIdentifier: String { get }
    func configure(with content: Content)
}
