//
//  UserDefaults.swift
//  GT
//
//  Created by MacBook on 4/26/20.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import UIKit

@propertyWrapper
struct AutoUserDefaults<T> {
    var key: String
    var defaultValue: T

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }

        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
