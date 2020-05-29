//
//  SectionPickerTableView.swift
//  GT
//
//  Created by Maksim Tochilkin on 25.04.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


final class SectionPickerTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        tableFooterView = UIView()
        register(SectionPickerCell.self, forCellReuseIdentifier: SectionPickerCell.reuseId)
        translatesAutoresizingMaskIntoConstraints = false
        alwaysBounceVertical = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}


class PropertyTapGestureRecognizer: UITapGestureRecognizer {
    var localObject: Any?
}
