//
//  UIView+Extension.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit


protocol NibLoadable {
    static func loadNib() -> UINib?
    static func loadView() -> Self?
}

extension NibLoadable where Self: UIView {
    static func loadView() -> Self? {
        let views = Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        return views?.first as? Self
    }
    
    static func loadNib() -> UINib? {
        UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

