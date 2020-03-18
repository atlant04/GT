//
//  SectionHeader.swift
//  GT
//
//  Created by MacBook on 3/17/20.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit

class SectionHeader: UICollectionReusableView {

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .title1), maximumPointSize: 24)
        return label
    }()

    let separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .quaternaryLabel
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [separator, title])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        addSubview(stack)
        stack.fill(self)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards??? Nah Chief")
    }
}
