//
//  AppConstants.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit

struct AppConstants {
    
    static let randomColors: [UIColor] = [.systemRed, .systemBlue, .systemGray, .systemTeal, .systemGray, .systemGreen, .systemOrange, .systemIndigo, .systemPurple, .systemYellow]
    static var shared = AppConstants()
    
    var userId: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    var currentTerm: String {
        get {
            UserDefaults.standard.value(forKey: "term") as? String ?? "Fall"
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "term")
        }
    }
    
    var allTerms: [String: String] = [
        "Fall": "202008",
        "Spring": "202005",
        "Summer": "202002"
    ]
    
    private init() { }
    
    let baseUrl =  "https://oscar-gt.herokuapp.com" //"https://oscarapp.appspot.com" 
    
    var coursesUrl: String {
        return baseUrl + EndPoints.courses.rawValue
    }
    
    var seatsUrl: String {
        return baseUrl + EndPoints.seats.rawValue
    }
    
    func testCourses(size: Int) -> String {
        return baseUrl + "/testCourses/\(size)"
    }
    
    var listenSectionUrl: String {
        return baseUrl + EndPoints.listenSection.rawValue
    }
    
    var unsubscribe: String {
        return baseUrl + EndPoints.unsubscribe.rawValue
    }
    
    
    enum EndPoints: String {
        case courses = "/courses"
        case seats = "/seats"
        case listenSection = "/listen/section"
        case unsubscribe = "/unsubscribe"
    }
}
