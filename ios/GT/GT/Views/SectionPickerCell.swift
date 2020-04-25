//
//  SectionPickerCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 25.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

final class SectionPickerCell: UITableViewCell {
    
    var isChosen: Bool = false {
        didSet {
            let image = isChosen ? UIImage(systemName: "plus.circle.fill") : UIImage(systemName: "plus.circle")
            chooseIcon.image = image
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    lazy var chooseIcon: UIImageView = {
        let image = UIImageView()
        image.image = isChosen ? UIImage(systemName: "plus.circle.fill") : UIImage(systemName: "plus.circle")
        image.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return image
    }()
       
    
    static var reuseId: String {
        return String(describing: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        
        selectionStyle = .none
        let stack = UIStackView(arrangedSubviews: [chooseIcon, label])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        contentView.addSubview(stack)
        fill(with: stack, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(section: Section) {
        label.text = section.id
    }
    
}
