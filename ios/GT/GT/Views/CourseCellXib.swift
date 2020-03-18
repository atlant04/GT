//
//  CourseCellXib.swift
//  GT
//
//  Created by MacBook on 3/16/20.
//  Copyright © 2020 MT. All rights reserved.
//

import UIKit

class CourseCellXib: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: Identifier = .courseCellXib

    func configure(with course: Course) {
        name.text = course.name
        identifier.text = course.identifier
        hours.text = course.hours
        instructor.text = course.sections?.first?.instructors.first ?? "None"
        sections.text = "# of sections \(course.sections?.count ?? 0)"
        view.backgroundColor = course.school.color
    }


    @IBOutlet weak var stack: UIStackView! {
        didSet {
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.distribution = .fillEqually
            stack.setCustomSpacing(5, after: identifier)
        }
    }

    @IBOutlet weak var view: UIView! {
        didSet {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 10
            view.isUserInteractionEnabled = true
            view.layer.cornerCurve = .continuous
        }
    }

    @IBOutlet weak var name: UILabel! {
        didSet {
            name.translatesAutoresizingMaskIntoConstraints = false
            name.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 12), maximumPointSize: 16)
            name.tintColor = .secondaryLabel
        }
    }

    @IBOutlet weak var hours: UILabel! {
        didSet {
            hours.translatesAutoresizingMaskIntoConstraints = false
            hours.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 10), maximumPointSize: 14)
            hours.tintColor = .tertiaryLabel
        }
    }

    @IBOutlet weak var instructor: UILabel! {
        didSet {
            instructor.translatesAutoresizingMaskIntoConstraints = false
            instructor.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 10), maximumPointSize: 14)
            instructor.tintColor = .tertiaryLabel
        }
    }

    @IBOutlet weak var sections: UILabel! {
        didSet {
            sections.translatesAutoresizingMaskIntoConstraints = false
            sections.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 10), maximumPointSize: 14)
            sections.tintColor = .tertiaryLabel
        }
    }

    @IBOutlet weak var identifier: UILabel! {
        didSet {
            identifier.translatesAutoresizingMaskIntoConstraints = false
            identifier.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16, weight: .bold), maximumPointSize: 20)
            identifier.tintColor = .label
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
