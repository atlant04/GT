//
//  AppConstants.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit

enum AppConstants {
    
    static let randomColors: [UIColor] = [.systemRed, .systemBlue, .systemGray, .systemTeal, .systemGray, .systemGreen, .systemOrange, .systemIndigo, .systemPurple, .systemYellow]
    
    static var currentTerm: String {
        get {
            UserDefaults.standard.value(forKey: "term") as? String ?? "Fall"
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "term")
        }
    }
    
    static var userId: String? {
        UIDevice().identifierForVendor?.uuidString
    }
    
    enum Term: String, CaseIterable {
        case Fall, Spring, Summer, Unknown
        
        init?(rawValue: String) {
            self = Term.allTerms[rawValue] ?? .Unknown
        }
        
        static private var allTerms: [String: Term] = [
            "202008": .Fall,
            "202005": .Spring,
            "202002": .Summer
        ]
    }
    
    enum AppURL {
        static let baseUrl =  "https://oscar-gt.herokuapp.com" //"https://oscarapp.appspot.com"

        
        static func testCourses(size: Int) -> String {
            return AppConstants.AppURL.baseUrl + "/testCourses/\(size)"
        }
        
        static func url(at endpoint: EndPoints) -> URL {
            return URL(string: AppConstants.AppURL.baseUrl + endpoint.rawValue)!
        }
        
        
        enum EndPoints: String {
            case courses = "/courses"
            case seats = "/seats"
            case listenSection = "/listen/section"
            case unsubscribe = "/unsubscribe"
        }
    }
    
}
