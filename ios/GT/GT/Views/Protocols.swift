//
//  Protocols.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation


protocol SelfConfiguringCell {
    static var reuseIdentifier: Identifier { get }
    func configure(with course: Course)
}
