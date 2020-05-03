//
//  CourseList.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


class CourseList: UICollectionViewController {
    let layout: UICollectionViewFlowLayout
    
    
    override func loadView() {
        super.loadView()
        collectionView = CompactCollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    init() {
        layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .leading, verticalAlignment: .center)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 6
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CourseListCell.self, forCellWithReuseIdentifier: CourseListCell.reuseIdentifier)
        collectionView.backgroundColor = UIColor.systemBackground
        collectionView.isScrollEnabled = false
    }
    
    override func viewWillLayoutSubviews() {
        print("Layout")
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        12
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseListCell.reuseIdentifier, for: indexPath)
        return cell
    }
    
}


class CompactCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }
    
    override func layoutSubviews() {
        invalidateIntrinsicContentSize()
        super.layoutSubviews()
    }
}

private final class CourseListCell: UICollectionViewCell, ConfiguringCell {
    typealias Content = Course
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    func configure(with content: Course) {
        
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "CS 1332"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.secondarySystemBackground
        contentView.layer.cornerRadius = 6
        self.fill(with: label, insets: .init(top: 4, left: 4, bottom: 4, right: 4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
