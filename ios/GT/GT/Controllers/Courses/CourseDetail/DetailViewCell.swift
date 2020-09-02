//
//  DetailViewCell.swift
//  GT
//
//  Created by Maksim Tochilkin on 22.07.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import SwiftUI
import MBProgressHUD

class DetailViewCell: UICollectionViewCell, ConfiguringCell {
    typealias Content = CourseDetailViewConroller.Item
    
    @IBOutlet weak var mainLabel: PaddedLabel!
    @IBOutlet weak var secondaryLabel: UILabel!
    
    var hud: MBProgressHUD?
    
    func configure(with content: CourseDetailViewConroller.Item) {
        switch content.state {
        case .loading:
            self.contentView.isHidden = true
            hud = MBProgressHUD.showAdded(to: self, animated: true)
            
        case .loaded(let string):
            self.mainLabel.text = string
            self.secondaryLabel.text = content.secondaryLabel
            self.contentView.isHidden = false
            hud?.hide(animated: true)
            hud = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        backgroundColor = .secondarySystemBackground
    }

}
