//
//  CourseCell.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit

class CourseCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: Identifier = .courseCell

       func configure(with course: Course) {
         name.text = course.name
         identifier.text = course.identifier
         hours.text = course.hours
        instructor.text = course.sections?.first?.instructors?.first ?? "None"
        sections.text = "# of sections \(course.sections?.count ?? 0)"
        contentView.backgroundColor = course.school?.color
     }

    let identifier: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold), maximumPointSize: 24)
        label.textColor = .label
        return label
    }()

    let name: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .semibold), maximumPointSize: 20)
        label.textColor = .label
        return label
    }()

    let hours: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .title2), maximumPointSize: 14)
        label.textColor = .label
        return label
    }()

    let instructor: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .title2), maximumPointSize: 14)
        label.textColor = .label
        return label
    }()

    let sections: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .title2), maximumPointSize: 14)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.contentMode = .scaleToFill
        contentView.layer.cornerRadius = 10
        contentView.layer.cornerCurve = .continuous
        let stack = UIStackView(arrangedSubviews: [identifier, name, hours, instructor, sections])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .center
        contentView.addSubview(stack)
        stack.fill(contentView)

    }

    required init?(coder: NSCoder) {
        fatalError("No storyboards please...")
    }
}


enum Identifier: String {
    case courseCell
    case courseCellXib
}
