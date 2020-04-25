//
//  SectionHeader.swift
//  GT
//
//  Created by MacBook on 3/17/20.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    
    static let titleElementKind = "section-kind"

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .largeTitle), maximumPointSize: 24)
        return label
    }()

    let separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternaryLabel
        return view
    }()
    
    let seeAllButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("See All", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        let hstack = UIStackView(arrangedSubviews: [title, seeAllButton])
        hstack.axis = .horizontal
        hstack.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [separator, hstack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        addSubview(stack)
        stack.fill(with: self, insets: UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 6))
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards??? Nah Chief")
    }
}
