//
//  CoursePickerCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 25.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

final class CoursePickerCell: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var course: Course? {
        didSet {
            label.text = course?.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        addSubview(stack)
        fill(with: stack, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        setupUI()
    }
    
    
//    func setupUI() {
//        backgroundColor = .secondarySystemBackground
//        layer.shouldRasterize = true
//        layer.rasterizationScale = UIScreen.main.scale
//        layer.borderWidth = 3.0
//        layer.cornerRadius = 8
//    }
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20.0
        layer.cornerCurve = .continuous
        layer.borderWidth = 3.0
        
        clipsToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.3
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = self.frame.insetBy(dx: 8, dy: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

