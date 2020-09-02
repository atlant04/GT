//
//  ScheduleItemHeaderView.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit
import Combine

final class ScheduleItemHeaderView: UIView, NibLoadable {
    
    var contentView: UIView!
    
    enum ButtonType {
        case info, brush, arrow
    }
    
    weak var delegate: PassthroughSubject<(ButtonType, Int), Never>?
    
    @IBOutlet weak var tertiary: UILabel!
    @IBOutlet weak var secondary: UILabel!
    @IBOutlet weak var main: UILabel!

    @IBAction func info(_ sender: Any) {
        delegate?.send((.info, self.tag))
    }
    
    @IBAction func brush(_ sender: Any) {
        delegate?.send((.brush, self.tag))
    }
    
    @IBAction func arrow(_ sender: UIButton) {
        delegate?.send((.arrow, self.tag))
        
        UIView.animate(withDuration: 0.4) {
            sender.transform3D = CATransform3DRotate(sender.transform3D, .pi, 0, 0, 1)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
//        contentView = ScheduleItemHeaderView.loadNib()
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}


