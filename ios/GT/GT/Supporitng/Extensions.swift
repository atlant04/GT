//
//  Extensions.swift
//  GT
//
//  Created by MacBook on 3/15/20.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit


//extension ObjectId: Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(self.description)
//    }
//}

extension UIView {
    func fill(_ view: UIView) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func center(in view: UIView) {
        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

extension Array {
    func keyMap<Key: Hashable>(with key: (Element) -> Key) -> [Key: [Element]] {
        var dict = [Key: [Element]]()
        for element in self {
            dict[key(element)]?.append(element)
        }
        return dict
    }
}

extension CaseIterable {
    static func getCases() -> [Self.AllCases.Element] {
        var array = [Self.AllCases.Element]()
        for element in Self.allCases {
            array.append(element)
        }
        return array
    }
}
