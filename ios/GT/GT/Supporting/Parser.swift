//
//  Parser.swift
//  GT
//
//  Created by MacBook on 4/17/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import MTWeekView


extension Collection {
    func flatten<Mapped>(_ map: (Self.Element) throws -> [Mapped]?) rethrows -> [Mapped] {
        try self.compactMap(map).reduce([], +)
    }
}
