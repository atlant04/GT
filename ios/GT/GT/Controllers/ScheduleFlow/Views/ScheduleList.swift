//
//  CourseList.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.05.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


class CourseList: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var alignedLayout: UICollectionViewFlowLayout
    
    var items = [ScheduleItem]() {
        didSet {
            reloadData()
        }
    }
    
    var onRemoveItem: ((ScheduleItem) -> Void)?
    
    var inEditMode = false
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        alignedLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .leading, verticalAlignment: .center)
        alignedLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        alignedLayout.minimumInteritemSpacing = 6
        super.init(frame: frame, collectionViewLayout: alignedLayout)
        
        register(CourseListCell.self, forCellWithReuseIdentifier: CourseListCell.reuseIdentifier)
        backgroundColor = UIColor.systemBackground
        isScrollEnabled = false
        dataSource = self
        delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func reloadData() {
        super.reloadData()
        collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CourseListCell.reuseIdentifier, for: indexPath) as! CourseListCell
        cell.label.text = items[indexPath.row].course?.identifier
        cell.contentView.backgroundColor = items[indexPath.row].color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard inEditMode else { return }
        onRemoveItem?(items[indexPath.row])
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }

    override func layoutSubviews() {
        invalidateIntrinsicContentSize()
        super.layoutSubviews()
        
    }
}


final class CourseListCell: UICollectionViewCell, ConfiguringCell {
    typealias Content = Course
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    func configure(with content: Course) {
        
    }
    
    var label: PaddedLabel = {
        let label = PaddedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "CS 1332"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.insets = .init(top: 4, left: 4, bottom: 4, right: 4)
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
        contentView.fill(with: label)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@IBDesignable
class PaddedLabel: UILabel {
    var insets: UIEdgeInsets?
    @IBInspectable var padding: CGFloat = 0 {
        didSet {
            insets = .all(padding)
            setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        guard let insets = insets else { return contentSize }
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        return contentSize
    }
}
