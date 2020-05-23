//
//  CourseCell.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit

var schoolColors: [String: UIColor] = [:]

class CourseCell: UICollectionViewCell, ConfiguringCell {
    static var reuseIdentifier: String = "course_cell"
    
    static let randomColors: [UIColor] = [.systemRed, .systemBlue, .systemGray, .systemTeal, .systemGray, .systemGreen, .systemOrange, .systemIndigo, .systemPurple, .systemYellow]
    
    func getSchoolColor(_ school: String) -> UIColor {
        if let color = schoolColors[school] {
            return color
        }
        let color = CourseCell.randomColors.randomElement()!
        schoolColors[school] = color
        return color
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 20.0
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 3.0
        
        contentView.clipsToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0.0,
                                                height: 4.0)
        contentView.layer.shadowRadius = 8.0
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    let colors: [UIColor] = [.systemRed, .systemBlue, .systemPurple, .systemPink, .systemTeal, .systemGreen, .systemIndigo, .systemPurple, .systemOrange]

       func configure(with course: Course) {
        name.text = course.name
        identifier.text = course.identifier
        hours.text = course.hours?.removeExtraSpaces()
        sections.text = "# of sections \(course.sections?.count ?? 0)"
        
        contentView.layer.borderColor = getSchoolColor(course.school ?? "Default").cgColor
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
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .label
        return label
    }()

    let hours: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .subheadline), maximumPointSize: 14)
        label.textColor = .label
        return label
    }()

    let instructor: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .subheadline), maximumPointSize: 14)
        label.textColor = .label
        return label
    }()

    let sections: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .subheadline), maximumPointSize: 14)
        label.textColor = .label
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        let stack = UIStackView(arrangedSubviews: [identifier, name, hours, sections])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .center
        contentView.addSubview(stack)
        contentView.fill(with: stack, insets: .all(4))
        //stack.fill(with: contentView, insets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))

    }

    required init?(coder: NSCoder) {
        fatalError("No storyboards please...")
    }
}


enum Identifier: String {
    case courseCell
    case courseCellXib
}
