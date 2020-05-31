//
//  MeetingCell.swift
//  GT
//
//  Created by MacBook on 4/17/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import MTWeekView


class MeetingCell: MTBaseCell{

   override func configure(with data: Event) {
        super.configure(with: data)
        if let meeting = data as? MeetingEvent {
            label.text = meeting.name
            if let colorStr = meeting.color {
                contentView.backgroundColor = UIColor(hex: colorStr)?.withAlphaComponent(0.9)
            }
        }
    }

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = min(bounds.height, bounds.width)
        contentView.layer.cornerRadius = min(side / 2, 10)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
        let color = UIColor(red: 94/255, green: 25/255, blue: 20/255, alpha: 0.9)
        contentView.backgroundColor = color
        contentView.layer.cornerCurve = .continuous
    }
    




    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
